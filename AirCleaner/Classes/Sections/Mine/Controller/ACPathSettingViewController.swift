//
//  ACPathSettingViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/8.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import TTSwitch

class ACPathSettingViewController: BaseViewController {
    
    @IBOutlet weak var openSwitch: TTFadeSwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tcpHostField: UITextField!
    @IBOutlet weak var tcpPortField: UITextField!
    @IBOutlet weak var openViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if let port = tcpPortField.text, port.count > 0 {
            StoreManager.shared.tcpPort = port
        } else {
            ProgressHUD.showError("请输入本地端口号")
        }
    }
}

extension ACPathSettingViewController {
    /// 设置UI
    fileprivate func setupUI() {
        tcpHostField.text = StoreManager.shared.tcpHost
        tcpPortField.text = StoreManager.shared.tcpPort
    }
    
    fileprivate func setupData() {
        //设置代理
        TcpModbusHandler.shareInstance.delegate = self
        /// 开关
        openSwitch.changeHandler = { [weak self] (on) in
            if let port = UInt16(StoreManager.shared.tcpPort), on {
                TcpModbusHandler.shareInstance.startServerHost(port: port)
            } else {
                TcpModbusHandler.shareInstance.serverInterruption()
                ProgressHUD.showSuccess("服务已断开")
            }
            
            self?.openSwitch.setOn = on
            self?.openViewHeight.constant = on ? 150.5 : 50
        }
        
        if let port = UInt16(StoreManager.shared.tcpPort) {
            TcpModbusHandler.shareInstance.startServerHost(port: port)
        }
    }
}

extension ACPathSettingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let port = Int(textField.text ?? "-1"), port > 0 && port < 65536 {
            saveButton.isEnabled = true
            return true
        } else {
            ProgressHUD.showError("端口号必须为0到65535")
            return false
        }
    }
}


extension ACPathSettingViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        return nil
    }
}
