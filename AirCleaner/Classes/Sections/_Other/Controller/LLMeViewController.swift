//
//  LLMeViewController.swift
//  LLProgramFrameworkSwift
//
//  Created by 奥卡姆 on 2017/9/5.
//  Copyright © 2017年 aokamu. All rights reserved.
//

import UIKit

class LLMeViewController: BaseViewController {
    
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    
    @IBOutlet weak var functionField: UITextField!
    @IBOutlet weak var deviceIDField: UITextField!
    @IBOutlet weak var adressField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var dataField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func CleanClick(_ sender: UIButton) {
        textView.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //获取ip地址
        hostField.text = ModbusTools.getIPAddress()
        tcpModbus.delegate = self
    }
    
    @IBAction func connectAction(_ sender: UIButton) {
        guard let port = UInt16(portField.text!) else {
            DLog("端口参数错误")
            return
        }
        //开启服务器
        tcpModbus.startServerHost(port: port)
        sender.setTitleColor(UIColor.red, for: .normal)
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        
        var function: kModbusFunctionCode!
        
        switch functionField.text! {
        case "03":
            function = kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters
        case "06":
            function = kModbusFunctionCode.modbusFunctionCodeWriteSingleRegister
        case "10":
            function = kModbusFunctionCode.modbusFunctionCodeWriteMultipleRegisters
        default:
            function = kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters
        }
        
        
        guard let deviceID = deviceIDField.text,
            let adress = Int(adressField.text!),
            let value = Int(valueField.text!),
            let count = Int(countField.text!),
            let dataStr = dataField.text else {
                DLog("参数错误")
                return
        }
        
        
        let dataArr = dataStr.components(separatedBy: ",")
        let dataNumArr = dataArr.map { (str) in
            return Int(str)
        }
        
        /*
         --------------------读--------------------
         5行        1001    开关量输入2状态(X1)    1:X1对GND短接  0:未短接  (下同)
         （读-例子） 01 03 03 E9 00 0A 14 7D
         上位机输出：01 03 14 00 00 00 00 00 00 00 00 0f ff 0f ff 0f ff 00 00 00 00 00 00 be ef
         说明: 20位输入（每个地址两个字节，1008~1019 为预留 00 00 00 00 00 00）
         */
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(withDeviceAddress: deviceID, functionCode: function, functionAddress: adress, registerCount: value, byteCount: count, data: dataNumArr as! [NSNumber]) {
            tcpModbus.send(data: data, type: .readBoard_1_pm5)
            tcpModbus.repeatPollData = data
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension LLMeViewController: TcpModbusHandlerDelegate {
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        textView.text = textView.text + message.description + "\n"
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
        return nil
    }
}
