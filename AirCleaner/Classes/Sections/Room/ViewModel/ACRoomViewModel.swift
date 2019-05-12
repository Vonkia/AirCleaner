//
//  ACRoomViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/3.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation
import RxSwift


let ACRoomCellID = "ACRoomCell"

class ACRoomViewModel: NSObject {
    
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    let bag : DisposeBag = DisposeBag()
    lazy var modelObserable = Variable<[ACRoomModel]> ([])
    var selectedModel: ACRoomModel?
    
    public func setConfig(_ tableView: UITableView) {
        // 设置代理
        tcpModbus.delegate = self
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: ACRoomCellID, cellType: ACRoomCell.self)){ [weak self] row , cellModel , cell in
                cell.cellModel = cellModel
                cell.intoCallBack = { (model) in
                    self?.selectedModel = model
                }
            }.disposed(by: bag)
    }
    
    ///刷新房间数据
    public func refreshRoomData() {
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters,
            functionAddress: ModbusProtocol.readBoard_1_switchState.rawValue,
            registerCount: 100, //读取100位
            byteCount: 0,
            data: []) {
            tcpModbus.send(data: data, type: .readBoard_1_switchState, isPoll: true)
            tcpModbus.repeatPollData = data
        }
    }
}

extension ACRoomViewModel: TcpModbusHandlerDelegate {
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        if message.count < 100 { return nil }
        var roomModelArr = [ACRoomModel]()
        for i in 0..<10 {
            //附板1的开关机状态  0--off  1--on
            let switchState = message[i*10]
            //附板1的风机状态  风速开度百分比
            let fanState = message[i*10+1]
            //附板1的PM.5值
            let pm5 = message[i*10+2]
            //附板1的温度值   此值需除以10,即250表示25.0摄氏度
            let tempValue = message[i*10+3]
            //附板1的湿度值
            let humiValue = message[i*10+4]
            
            if switchState == "1" {
                let model = ACRoomModel()
                let row = roomModelArr.count - 1
                //设置房间名字
                model.title = "房间 \(String(format: "%02d", row + 1))"
                //设置协议类型
                model.type = ModbusProtocol(rawValue: ModbusProtocol.readBoard_1_switchState.rawValue + row * 10)
                //附板1的开关机状态  0--off  1--on
                model.switchState = switchState
                //附板1的风机状态  风速开度百分比
                model.fanState = fanState
                //附板1的PM.5值
                model.pm5 = pm5
                //附板1的温度值   此值需除以10,即250表示25.0摄氏度
                model.tempValue = tempValue
                //附板1的湿度值
                model.humiValue = humiValue
                
                roomModelArr.append(model)
            }
        }
        /*
         ["0", "0", "133", "589", "67", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "100", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"]
         */
        modelObserable.value = roomModelArr
        return nil
    }
}
