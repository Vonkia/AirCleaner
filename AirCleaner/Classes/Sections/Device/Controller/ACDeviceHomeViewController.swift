//
//  ACDeviceHomeViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/2.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import MJRefresh

class ACDeviceHomeViewController: BaseViewController {
    
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    //指针初始位置
    let mp5PointImgViewDefaultTransformValue: CGFloat = 5.87
    
    // case readBoard_1_switchState        = 1100 //附板1的开关机状态  0--off  1--on
    
    /// 1101 附板1的风机状态  风速开度百分比
    @IBOutlet weak var fanStateSlider: UISlider!
    /// 附板1的PM.5值
    @IBOutlet weak var mp5PointImgView: UIImageView!
    @IBOutlet weak var pm5DescLabel: UILabel!
    @IBOutlet weak var pm5ValueLabel: UILabel!
    //附板1的温度值   此值需除以10,即250表示25.0摄氏度
    @IBOutlet weak var tempValueLabel: UILabel!
    //附板1的湿度值
    @IBOutlet weak var humiValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    ///一键关机
    @IBAction func switchAction(_ sender: UIButton) {
        //写数据
        sender.isSelected = !sender.isSelected
        //附板1:开关机控制  0--关机  1--开机
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeWriteSingleRegister,
            functionAddress: ModbusProtocol.writeBoard_1_switchState.rawValue,
            registerCount: 0, //当一位时候写时为0
            byteCount: 0,
            data: [sender.isSelected ? 0 : 1]) {
            tcpModbus.send(data: data, type: .writeBoard_1_switchState, isPoll: false)
        }
    }
    
    ///运行状态
    @IBAction func fanAction(_ sender: UIButton) {
        
        let dataArr = ["第一档", "第二档", "第三档"]
        let vc = ACSheetController(title: "请选择风档", dataArr: dataArr, sheetAction: { (index) in
            DLog("\(index) ☑️")
        })
        self.present(vc, animated: true, completion: nil)
        return
            
        //写数据
        sender.isSelected = !sender.isSelected
        //附板1:风机运行控制    0--自动  1--手动低档  2--手动中档  3--手动高档
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeWriteSingleRegister,
            functionAddress: ModbusProtocol.writeBoard_1_fanState.rawValue,
            registerCount: 0, //当一位时候写时为0
            byteCount: 0,
            data: [sender.isSelected ? 0 : 1]) {
            tcpModbus.send(data: data, type: .writeBoard_1_switchState, isPoll: false)
        }
    }
    
    ///一键调速
    @IBAction func fanStateSliderAction(_ sender: UISlider) {
        
        
    }
}

extension ACDeviceHomeViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        // mp5PointImgView.backgroundColor = UIColor.green
        mp5PointImgView.layer.anchorPoint = CGPoint(x: 0.915, y: 0.5)
        //总共有40格 每一格子=0.1，每一单位值=0.008
        mp5PointImgView.transform = CGAffineTransform(rotationAngle: mp5PointImgViewDefaultTransformValue)
    }
    
    fileprivate func setupData() {
        DLog(ModbusTools.getIPAddress())
        
        // iwevon 开启服务器
        tcpModbus.delegate = self
        
        if let data = ModbusTools.calculateMultiRegistersModbusRTUBytes(
            withDeviceAddress: "01",
            functionCode: kModbusFunctionCode.modbusFunctionCodeReadHoldingRegisters,
            functionAddress: ModbusProtocol.readBoard_1_switchState.rawValue,
            registerCount: 5, //读取5位
            byteCount: 0,
            data: []) {
                tcpModbus.send(data: data, type: .readBoard_1_switchState)
                tcpModbus.repeatPollData = data
        }
    }
    
    fileprivate func resetData() {
        /// 1101 附板1的风机状态  风速开度百分比
        fanStateSlider.value = 0
        /// 附板1的PM.5值
        // 1.指针
        //总共有40格 每一格子=0.1，每一单位值=0.008
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.mp5PointImgView.transform = CGAffineTransform(rotationAngle: (self?.mp5PointImgViewDefaultTransformValue)!)
        }
        // 2.描述
        self.pm5DescLabel.text = " "
        // 3.值
        self.pm5ValueLabel.text = " "
        //附板1的温度值   此值需除以10,即250表示25.0摄氏度
        tempValueLabel.text = "-℃"
        //附板1的湿度值
        humiValueLabel.text = "-%"
    }
}

extension ACDeviceHomeViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        
        if type == .readBoard_1_switchState {
            if message.count < 5 {
                self.resetData()
            } else {
                /// 1101 附板1的风机状态  风速开度百分比
                fanStateSlider.value = Float(message[1])! / 100.0
                /// 附板1的PM.5值
                let pm5 = Float(message[2])!
                // 1.指针
                //总共有40格 每一格子=0.1，每一单位值=0.008
                var pm5TransformValue = mp5PointImgViewDefaultTransformValue
                if pm5 >= 500 {
                    pm5TransformValue += (0.008 * 500)
                } else {
                    pm5TransformValue += CGFloat(0.008 * pm5)
                }
                UIView.animate(withDuration: 1.0) { [weak self] in
                    self?.mp5PointImgView.transform = CGAffineTransform(rotationAngle: pm5TransformValue)
                }
                // 2.描述
                if pm5 >= 301 {
                    self.pm5DescLabel.text = "有毒害"
                    self.pm5ValueLabel.textColor = RGBCOLOR(114, 40, 62)
                } else if pm5 >= 201 {
                    self.pm5DescLabel.text = "非常差"
                    self.pm5ValueLabel.textColor = RGBCOLOR(156, 28, 95)
                } else if pm5 >= 151 {
                    self.pm5DescLabel.text = "很差"
                    self.pm5ValueLabel.textColor = RGBCOLOR(148, 13, 83)
                } else if pm5 >= 101 {
                    self.pm5DescLabel.text = "较差"
                    self.pm5ValueLabel.textColor = RGBCOLOR(251, 21, 32)
                } else if pm5 >= 51 {
                    self.pm5DescLabel.text = "一般"
                    self.pm5ValueLabel.textColor = RGBCOLOR(252, 136, 37)
                } else {
                    self.pm5DescLabel.text = "良"
                    self.pm5ValueLabel.textColor = RGBCOLOR(92, 210, 119)
                }
                // 3.值
                self.pm5ValueLabel.text = "\(Int(pm5))"
                
                //附板1的温度值   此值需除以10,即250表示25.0摄氏度
                let tempValue = Float(message[3])! / 10.0 - 40
                tempValueLabel.text = "\(String(format: "%.1f", tempValue))℃"
                //附板1的湿度值
                humiValueLabel.text = "\(message[4])%"
            }
        }
        else if type == .writeBoard_1_switchState {
            if message.last == "0" {
                self.resetData()
                return nil
            } else {
                return .readBoard_1_switchState
            }
        }
        return nil
    }
}
