//
//  ACRoomTimeSettingViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/3.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import MJRefresh
import TTSwitch


class ACRoomTimeSettingViewController: BaseViewController {
    //当前的地址
    var modbusType: ModbusProtocol!
    
    //定时开关
    @IBOutlet weak var timeSwitch: TTFadeSwitch!
    @IBOutlet weak var timeHeight: NSLayoutConstraint!
    //第一组
    @IBOutlet weak var group_1_Switch: TTFadeSwitch!
    @IBOutlet weak var group_1_Height: NSLayoutConstraint!
    //第二组
    @IBOutlet weak var group_2_Switch: TTFadeSwitch!
    @IBOutlet weak var group_2_Height: NSLayoutConstraint!
    //附板1：周1~周5 开启 第1组
    @IBOutlet weak var openGroup_1_Label: UILabel!
    //附板1：周1~周5 关闭 第1组
    @IBOutlet weak var closeGroup_1_Label: UILabel!
    //附板1：周1~周5 开启 第2组
    @IBOutlet weak var openGroup_2_Label: UILabel!
    //附板1：周1~周5 关闭 第2组
    @IBOutlet weak var closeGroup_2_Label: UILabel!
    //当前的Label
    var currentLabel: UILabel?
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    
    //附板1：周1~周5 开启 第1组
    //附板1：周1~周5 关闭 第1组
    //附板1：周1~周5 开启 第2组
    //附板1：周1~周5 关闭 第2组
    @IBAction func timeAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            currentLabel = openGroup_1_Label
        case 2:
            currentLabel = closeGroup_1_Label
        case 3:
            currentLabel = openGroup_2_Label
        case 4:
            currentLabel = closeGroup_2_Label
        default:
            currentLabel = nil
            break
        }
        currentLabel?.tag = 0
        let date = Date.formatter("HH:mm", dateString: currentLabel!.text)
        datePickerAction(date)
    }
    
    //点击时间
    @IBAction func datePickerConfirmAction(_ sender: UIButton) {
        
        switch currentLabel! {
        case openGroup_1_Label:
            currentLabel?.tag = modbusType.rawValue
        case closeGroup_1_Label:
            currentLabel?.tag = modbusType.rawValue + 2
        case openGroup_2_Label:
            currentLabel?.tag = modbusType.rawValue + 4
        case closeGroup_2_Label:
            currentLabel?.tag = modbusType.rawValue + 6
        default:
            currentLabel?.tag = 0
            break
        }
    }
    //时间选择
    fileprivate func datePickerAction(_ scrollToDate: Date) {
        let datepicker = WSDatePickerView(dateStyle: DateStyleShowHourMinute, scrollTo: scrollToDate) { (date) in
            self.setupTime(date!)
        }
        datepicker?.hiddenYearLabel = true
        datepicker?.show()
    }
    
    //设置时间
    fileprivate func setupTime(_ selDate: Date) {        
        let dateStr = selDate.formatter("HH:mm")
        self.currentLabel?.text = dateStr
        let dateArr = dateStr.components(separatedBy: ":")
        
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeWriteMultipleRegisters,
            functionAddress: (currentLabel?.tag)!,
            registerCount: 2, //写两组数据，如果只写一位：0
            byteCount: 4, //写入4个字节，如果只写一位：0
            data: [Int(dateArr.first!)! as NSNumber, Int(dateArr.last!)! as NSNumber]) {
            tcpModbus.send(data: data, type: .writeBoard_1_switchState, isPoll: false)
        }
    }
    
    //删除此时间
    @IBAction func deleteTimeAction(_ sender: UIButton) {
        //1.设置关闭
        ProgressHUD.showSuccess("删除时间成功，暂未处理")
    }
}

extension ACRoomTimeSettingViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        //跳转前设置
        modbusType = ModbusProtocol.readWriteBoard_1_workDayOpenHourGroup_1
        
        //定时开关
        timeSwitch.changeHandler = { [weak self] (on) in
            self?.timeSwitch.setOn = on
            self?.timeHeight.constant = on ? 421 : 50
        }
        //第一组
        group_1_Switch.changeHandler = { [weak self] (on) in
            self?.group_1_Switch.setOn = on
            self?.group_1_Height.constant = on ? 150.5 : 50
        }
        //第二组
        group_2_Switch.changeHandler = { [weak self] (on) in
            self?.group_2_Switch.setOn = on
            self?.group_2_Height.constant = on ? 150.5 : 50
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
            functionAddress: ModbusProtocol.readWriteBoard_1_workDayOpenHourGroup_1.rawValue,
            registerCount: 8, //读取8位
            byteCount: 0,
            data: []) {
            tcpModbus.send(data: data, type: .readBoard_1_switchState, isPoll: true)
            tcpModbus.repeatPollData = data
        }
    }
}


extension ACRoomTimeSettingViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        
        if let currentLab = currentLabel, currentLab.tag != 0 {
            currentLab.tag = 0
            return modbusType
        }
        
        if message.count < 8 { return nil }
        //附板1：周1~周5 开启 第1组
        openGroup_1_Label.text = String(format: "%02d:%02d", Int(message[0]) ?? 0, Int(message[1]) ?? 0)
        //附板1：周1~周5 关闭 第1组
        closeGroup_1_Label.text = String(format: "%02d:%02d", Int(message[2]) ?? 0, Int(message[3]) ?? 0)
        //附板1：周1~周5 开启 第2组
        openGroup_2_Label.text = String(format: "%02d:%02d", Int(message[4]) ?? 0, Int(message[5]) ?? 0)
        //附板1：周1~周5 关闭 第2组
        closeGroup_2_Label.text = String(format: "%02d:%02d", Int(message[6]) ?? 0, Int(message[7]) ?? 0)
        return nil
    }
}
