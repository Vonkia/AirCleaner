//
//  ACRoomTimeListViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import MJRefresh


let ACRoomTimeCellID = "ACRoomTimeCell"

import UIKit
import RxSwift
import RxCocoa
import Moya
import MJRefresh
import TTSwitch


class ACRoomTimeListViewController: BaseViewController {
    //当前的地址
    var modbusType: ModbusProtocol!
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    
    /// 周1~周5 开关
    @IBOutlet weak var workDaySwitch: TTFadeSwitch!
    /// 周六~周日 开关
    @IBOutlet weak var weekendSwitch: TTFadeSwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    //时间开关设置
    @IBAction func setupTimeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setupTime(switchOn: sender.isSelected, type: .readWriteBoard_1_workDaySetting)
    }
}

extension ACRoomTimeListViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        //跳转前设置
        modbusType = ModbusProtocol.readWriteBoard_1_workDaySetting
        //设置switch开关
        setupSwitchUI()
    }
    
    /// 设置switch开关
    fileprivate func setupSwitchUI() {
        
        /// 周1~周5 开关
        workDaySwitch.changeHandler = { [weak self] (on) in
            self?.workDaySwitch.setOn = on
        }
        /// 周六~周日 开关
        weekendSwitch.changeHandler = { [weak self] (on) in
            self?.weekendSwitch.setOn = on
        }
    }
    
    fileprivate func setupData() {
        DLog(ModbusTools.getIPAddress())

        // iwevon 开启服务器
        tcpModbus.delegate = self
        
        readTimeData()
    }
    
    ///刷新时间数据
    fileprivate func readTimeData() {
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters,
            functionAddress: modbusType.rawValue,
            registerCount: 18, //读取18位
            byteCount: 0,
            data: []) {
            tcpModbus.send(data: data, type: .readWriteBoard_1_workDaySetting, isPoll: true)
            tcpModbus.repeatPollData = data
        }
    }
    
    //设置时间
    fileprivate func setupTime(switchOn: Bool, type: ModbusProtocol) {
        //附板1：周1~周5 定时开启设定  0--off  1--on   readWriteBoard_1_workDaySetting
        //附板1：周6~周日 定时开启设定  0--off  1--on   readWriteBoard_1_weekendSetting
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeWriteSingleRegister,
            functionAddress: type.rawValue,
            registerCount: 0, //当一位时候写时为0
            byteCount: 0,
            data: [switchOn ? 1 : 0]) {
            tcpModbus.send(data: data, type: type, isPoll: false)
        }
    }
}


extension ACRoomTimeListViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        if type == .readWriteBoard_1_workDaySetting {
            if message.count < 18 { return nil }
            
            /* ["1", "1", "7", "2", "15", "9", "15", "10", "15", "32", "15", "13", "15", "14", "15", "15", "15", "16"]*/
            //附板1：周1~周5 定时开启设定  0--off  1--on
            let workDaySetting = (message[0] == "1") ? true : false
            //附板1：周6~周日 定时开启设定  0--off  1--on
            let weekendSetting = (message[1] == "1") ? true : false
            
            //附板1：周1~周5 第1组 第一组：09:00~11:00
            let workDayGroup_1 = String(format: "第一组：%02d:%02d~%02d:%02d", Int(message[2]) ?? 0, Int(message[3]) ?? 0, Int(message[4]) ?? 0, Int(message[5]) ?? 0)
            //附板1：周1~周5 第2组 第二组：19:00~21:00
            let workDayGroup_2 = String(format: "第二组：%02d:%02d~%02d:%02d", Int(message[6]) ?? 0, Int(message[7]) ?? 0, Int(message[8]) ?? 0, Int(message[9]) ?? 0)
            
            //附板1：周六~周日 第1组 第一组：09:00~11:00
            let weekendGroup_1 = String(format: "第一组：%02d:%02d~%02d:%02d", Int(message[10]) ?? 0, Int(message[11]) ?? 0, Int(message[12]) ?? 0, Int(message[13]) ?? 0)
            //附板1：周六~周日 第2组 第二组：19:00~21:00
            let weekendGroup_2 = String(format: "第二组：%02d:%02d~%02d:%02d", Int(message[14]) ?? 0, Int(message[15]) ?? 0, Int(message[16]) ?? 0, Int(message[17]) ?? 0)
            
            return modbusType
        }
        
        return nil
    }
}


//MARK: - ACRoomTimeCell
class ACRoomTimeCell: UITableViewCell {
    
    var type: ModbusProtocol?
    var intoCallBack: ((_ title: String?, _ type: ModbusProtocol?)->())?
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func intoAction(_ sender: UIButton) {
        if intoCallBack != nil { intoCallBack!(titleLbl.text, type) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
