//
//  ACDeviceConnectViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class ACDeviceConnectViewController: BaseViewController {
    
    /// 空气净化器模型
    var deviceModel: ACDeviceModel?
    /// 设备型号
    @IBOutlet weak var deviceMarkerField: UITextField!
    /// 设备序列号
    @IBOutlet weak var deviceNumField: UITextField!
    /// 设备密码
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    /// 连接设备
    @IBAction func contentAction(_ sender: UIButton) {
        StoreManager.shared.useAirCleaner = self.deviceModel
        self.jumpDeviceFrontViewController()
    }
    /// 删除设备
    @IBAction func deleteActionm(_ sender: UIBarButtonItem) {
        SQLiteManager.deviceCaches.delData(_key: self.deviceModel?.num)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ACDeviceConnectViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        /// 设备型号
        deviceMarkerField.text = deviceModel?.marker
        /// 设备序列号
        deviceNumField.text = deviceModel?.num
        /// 设备密码
        passwordField.text = deviceModel?.password
    }
    
    fileprivate func setupData() {
        
    }
    
    // 跳转到设备首页
    fileprivate func jumpDeviceFrontViewController() {
        //重新开启服务器
        if let port = UInt16(StoreManager.shared.tcpPort) {
            TcpModbusHandler.shareInstance.serverInterruption()
            TcpModbusHandler.shareInstance.startServerHost(port: port)
        }
        //跳转界面
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ACDeviceFrontViewController") as! ACDeviceFrontViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
