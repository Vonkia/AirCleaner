//
//  ACDeviceFrontViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class ACDeviceFrontViewController: BaseViewController {
    
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    //当前设备模型
    var defaultModel: ACDeviceModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
}

extension ACDeviceFrontViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        
    }
    
    fileprivate func setupData() {
        // 设置代理
        tcpModbus.delegate = self
    }
    
    
    /// storyboard跳转
    /*
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ACDeviceHomeViewController" && self.defaultModel == nil {
            ProgressHUD.showError("请等待设备连接！")
            return false
        }
        return true
    }
     */
    
    // 下个界面跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let viewController = segue.destination as? ACDeviceConnectViewController,
//            let deviceModel = viewModel.selectedModel {
//            viewController.deviceModel = deviceModel
//        }
    }
}

extension ACDeviceFrontViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理,处理完成回调
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        return nil
    }
    
    //设备连接状态改变
    func deviceConnect(didStatusChange deviceArray: [ACDeviceModel], clientSocketConnect defaultDeviceConnect: Bool) {
        if defaultDeviceConnect {
            ProgressHUD.showInfo("设备已成功连接！")
        }
    }
}
