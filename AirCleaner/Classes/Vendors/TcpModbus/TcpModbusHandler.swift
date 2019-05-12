//
//  TcpModbusHandler.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/29.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import Alamofire

protocol TcpModbusHandlerDelegate: NSObjectProtocol {
    //接收消息代理,处理完成回调
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol?
    
    //@optional
    //发送消息超时代理
    func sendMessageTimeOut(tag: Int)
    //Wi-Fi连接状态监听
    func listenWifi(status: Bool)
    //设备连接状态改变
    func deviceConnect(didStatusChange deviceArray: [ACDeviceModel], clientSocketConnect defaultDeviceConnect: Bool)
}

extension TcpModbusHandlerDelegate {
    //发送消息超时代理
    func sendMessageTimeOut(tag: Int) { DLog(tag) }
    //Wi-Fi连接状态监听
    func listenWifi(status: Bool) { DLog(status) }
    //设备连接状态改变
    func deviceConnect(didStatusChange deviceArray: [ACDeviceModel], clientSocketConnect defaultDeviceConnect: Bool) { DLog(deviceArray) }
}


class TcpModbusHandler: NSObject {
    // 单例
    static let shareInstance = TcpModbusHandler.init()
    //所有的代理
    weak var delegate: TcpModbusHandlerDelegate?
    //重复轮询的数据
    var repeatPollData: Data?
    //当前连接的设备
    lazy var deviceModelArr = [ACDeviceModel]()
    
    // MAKR: 私有属性
    //检测网络
    fileprivate let reachability = NetworkReachabilityManager(host: TCP_PingUrl)
    //所有的客户端
    fileprivate lazy var clientSockets = [GCDAsyncSocket]()
    //自动重连次数
    fileprivate var autoConnectCount = TCP_AutoConnectCount
    //心跳频率(永远.never)
    fileprivate let pageStepTime: DispatchTimeInterval = .seconds(5)
    //socket连接状态
    fileprivate var connectStatus: SocketConnectStatus!
    //初始化聊天
    fileprivate var modbusSocket: GCDAsyncSocket!
    //数据协议类型
    fileprivate var modbusDataType: ModbusProtocol!
    //客户端
    fileprivate var clientSocket: GCDAsyncSocket?
    //轮询次数
    fileprivate var pollCount: Int = 0
    //轮询开启
    fileprivate var isPollOn = true
    //端口号
    fileprivate var port: UInt16 = TCP_Port
    
    //心跳定时器
    fileprivate lazy var beatTimer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.schedule(deadline: .now(), repeating: self.pageStepTime)
        timer.setEventHandler { [weak self] in
            //发送心跳 +1
            #if DEBUG
                self?.pollCount += 1
                if (self?.pollCount)! > 10000 { self?.pollCount = 0 }
                DLog("轮询：\(String(describing: self?.pollCount))")
            #endif

            //重复轮询
            if let data = self?.repeatPollData, (self?.isPollOn)! {
                self?.send(data: data, type: (self?.modbusDataType)!)
            }
        }
        return timer
    }()
    
    override init() {
        super.init()
        //将handler设置成接收TCP信息的代理
        self.modbusSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        //设置默认关闭读取
        self.modbusSocket.autoDisconnectOnClosedReadStream = false
        //默认状态未连接
        self.connectStatus = .unConnected
        //设置端口
        self.port = UInt16(StoreManager.shared.tcpPort)!
        //网络监听
        self.networkChanged()
    }
    
    deinit {
        //关闭网络监听
        self.stopNetworkListen()
        //取消轮询
        self.beatTimer.suspend()
    }
}


//MARK: - public方法
extension TcpModbusHandler {
    
    //开启网络监听
    public func startNetworkListen() {
        self.reachability?.startListening()
    }
    
    //关闭网络监听
    public func stopNetworkListen() {
        self.reachability?.stopListening()
    }
    
    //MARK: - 开启服务器端口
    public func startServerHost(port: UInt16) {
        if connectStatus == .connected { return }
        guard reachability?.networkReachabilityStatus == .reachable(.ethernetOrWiFi) else {
            ProgressHUD.showError("请检查Wi-Fi连接")
            return
        }
        
        do {
            self.port = port
            try modbusSocket.accept(onPort: port)
            self.connectStatus = .connected
            ProgressHUD.showSuccess("服务已开启")
            DLog("\(String(describing: ModbusTools.getIPAddress())):\(TCP_Port)服务开启成功")
        } catch {
            DLog("服务开启失败 - \(error)")
        }
    }
    
    //MARK: - 连接中断
    public func serverInterruption() {
        if self.connectStatus == .unConnected { return }
        //更新soceket连接状态
        self.connectStatus = .closeConnected
        self.disconnect()
        DLog("\(String(describing: ModbusTools.getIPAddress())):\(TCP_Port)服务已断开")
    }
    
    //MARK: - 断开连接
    public func disconnect() {
        //客户端
        self.clientSockets.removeAll()
        self.clientSocket = nil
        //取消连接
        self.modbusSocket.disconnect()
        //未接收到服务器心跳次数,置为初始化
        self.pollCount = 0
        //自动重连次数 , 置为初始化
        self.autoConnectCount = TCP_AutoConnectCount;
        //取消轮询
        self.beatTimer.suspend()
        //清空数据
        self.clientSockets.removeAll()
        self.clientSocket = nil
    }
    
    //MARK: - 发送数据
    public func send(data: Data, type: ModbusProtocol, isPoll: Bool = true) {
        // clientSocket?.write(data, withTimeout: -1, tag: 0)
        /* 监听客户端有没有数据上传
         timeout -1 代表不超时
         tag 标识作用，现在不用，就写0
         */
        DLog("App发送的数据\(ModbusTools.convertDataBytes(toHex: data))")
        self.modbusDataType = type
        self.isPollOn = isPoll
        // 设置了唯一客户端就不对所有客户端实现监听
        if self.clientSocket != nil {
            self.clientSocket?.write(data, withTimeout: -1, tag: 0)
            self.clientSocket?.readData(withTimeout: -1, tag: 0)
        } else {
            for clientS in self.clientSockets {
                clientS.write(data, withTimeout: -1, tag: 0)
                clientS.readData(withTimeout: -1, tag: 0)
            }
        }
    }
    
    //MARK: - 网络监听
    fileprivate func networkChanged() {
        self.reachability?.listener = { [weak self] (status) in
            //如果网络监测有网 , 但是socket处于未连接状态 , 进行重连
            if status == .reachable(.ethernetOrWiFi) {
                //Wi-Fi状态回调
                self?.delegate?.listenWifi(status: true)
                if self?.connectStatus == .unConnected {
                    //开启服务器
                    self?.startServerHost(port: (self?.port)!)
                }
            } else {
                //Wi-Fi状态回调
                self?.delegate?.listenWifi(status: false)
                if self?.connectStatus != .unConnected {
                    //断开连接
                    self?.serverInterruption()
                    ProgressHUD.showError("服务已断开，请检查Wi-Fi连接")
                }
            }
        }
        self.startNetworkListen()
    }
    
    //MARK: - 发送读取设备编号数据
    fileprivate func readHostNumberASCII(client: GCDAsyncSocket) {
        // 1.保持客户端(增加客户端设备到socket列表中)
        self.clientSockets.append(client)
        // 2.创建一个临时的设备Model到数组中
        self.deviceModelArr.append(ACDeviceModel(tempNum: String(self.clientSockets.count)))
        // 3.开启定时器轮询
        if self.clientSockets.count == 1 {
            self.beatTimer.resume()
        }
        // 4.获取设备编号
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters,
            functionAddress: ModbusProtocol.readHostNumberASCII_1.rawValue,
            registerCount: 12, //读取12位
            byteCount: 0,
            data: []) {
            //发送读取设备编号数据
            client.write(data, withTimeout: -1, tag: 0)
            //继续监听客户端有没有数据上传
            client.readData(withTimeout: -1, tag: 0)
        }
    }
    
    //MARK: - 校验客户端设备
    fileprivate func checkClientSocketConnection(client: GCDAsyncSocket, message: [String]) {
        /* 列子 ["56", "48", "49", "51", "54", "48", "50", "56", "56", "48", "49", "55"]
         801360288017 */
        // 上位机返回的数据 01 03 16 00 38 00 30 00 31 00 33 00 36 00 30 00 32 00 38 00 38 00 30 00 31 00 37 be ef
        
        // 1.如果存在此设备
        guard let index = self.clientSockets.index(of: client) else { return }
        // 1.设备编号是12位，过滤1(判断传入的数据)
        if message.count != 12 { return }
        // 2.将ASCII数据转换成字符串
        var deviceNum = ""
            // let arr1 = (0..<5).map { "\($0)" }
        for i in 0..<message.count {
            let num = Int(message[i]) ?? 0
            let assciiStr = UnicodeScalar(num)?.escaped(asASCII: true) ?? ""
            deviceNum.append(assciiStr)
        }
        // 3.设备编号是12位，过滤2(判断转换后的字符串)
        if deviceNum.count != 12 { return }
        // 4.在自己的设备列表中是否包含当前的设备编号
        guard let curModel = StoreManager.shared.airCleanerArr.filter({
            return $0.num == deviceNum
        }).first else {
            // 移除此设备的连接
            self.clientSockets.remove(at: index)
            self.deviceModelArr.remove(at: index)
            if self.clientSockets.count == 0 { //没有设备连接时
                self.beatTimer.suspend() // 取消定时器轮询
                self.clientSocket = nil // 设备设置nil
            }
            return
        }
        // 5.替换deviceModel为有效的Model
        self.deviceModelArr[index] = curModel
        // 6.判断当前设备连接是否是正在使用的设备,如果正在使用，则设置正在使用的客户端
        if StoreManager.shared.useAirCleaner?.num == deviceNum {
            self.clientSocket = client
        }
        // 7.设备连接状态改变回调
        delegate?.deviceConnect(didStatusChange: self.deviceModelArr, clientSocketConnect: self.clientSocket == nil ? false : true)
    }
    
    //MARK: - 移除客户端
    fileprivate func remveClient(client: GCDAsyncSocket) {
        // 1.如果存在此设备
        guard let index = self.clientSockets.index(of: client) else { return }
        // 2.移除此设备的连接
        self.clientSockets.remove(at: index)
        self.deviceModelArr.remove(at: index)
        // 3.没有设备连接时
        if self.clientSockets.count == 0 {
            self.beatTimer.suspend() // 取消定时器轮询
            self.clientSocket = nil // 设备设置nil
        }
        // 4.设备连接状态改变回调
        delegate?.deviceConnect(didStatusChange: self.deviceModelArr, clientSocketConnect: self.clientSocket == nil ? false : true)
    }
}

extension TcpModbusHandler: GCDAsyncSocketDelegate {
    
    //MARK: - 有客户端的socket连接到服务器
    internal func socket(_ serverSock: GCDAsyncSocket, didAcceptNewSocket clientSock: GCDAsyncSocket) {
        DLog("[\(self.clientSockets.count)] serverSocket:\(String(describing: clientSock.connectedHost)) \(clientSock.connectedPort) clientSocket: \(clientSock)\n")
        // 发送读取设备编号数据
        self.readHostNumberASCII(client: clientSock)
    }
    
    //MARK: - 接收到消息
    internal func socket(_ clientSock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // 0.CRC校验（暂时需要调试，先不做判断）
        
        // 1.把NSData转需要的类型
        guard let responseArr = ModbusTools.calculateReadResponseModbusData(data) else {
            DLog("上位机返回的数据格式有误")
            return
        }
        // 2.增加客户端设备到socket列表中
        self.checkClientSocketConnection(client: clientSock, message: responseArr)
        DLog("上位机返回的数据：\(data), \n 数组：\(responseArr)")
        // 3.处理请求，返回数据给客户端
        if let returnType = delegate?.didReceive(message: responseArr, type: modbusDataType) {
            DLog("返回的类型：\(returnType)")
            self.modbusDataType = returnType
            self.isPollOn = true
        }
        // 4.每次读完数据后，都要调用一次监听数据的方法
        clientSock.readData(withTimeout: -1, tag: 0)
    }
    
    //MARK: - 写入数据成功 , 重新开启允许读取数据
    internal func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {

    }
    
    //MARK: - 消息发送超时
    func socket(_ clientSock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        self.delegate?.sendMessageTimeOut(tag: tag)
        return -1
    }
    
    //MARK: - TCP已经断开连接
    internal func socketDidDisconnect(_ clientSock: GCDAsyncSocket, withError err: Error?) {
        // 移除客户端
        self.remveClient(client: clientSock)
    }
}
