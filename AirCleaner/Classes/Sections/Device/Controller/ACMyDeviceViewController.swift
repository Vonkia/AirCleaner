//
//  ACMyDeviceViewController.swift
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

class ACMyDeviceViewController: BaseViewController {
    
    /// 添加设备
    @IBOutlet weak var addItem: UIBarButtonItem!
    /// 空气净化器
    @IBOutlet weak var airCleanerDescLabel: UILabel!
    /// 空气净化器模型
    var deviceModel: ACDeviceModel? {
        didSet {
            airCleanerDescLabel.text = "主机编号：\(deviceModel?.marker ?? "")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.deviceModel = StoreManager.shared.useAirCleaner
    }
    
    /// 暂未开发设备点击
    @IBAction func otherDeviceAction(_ sender: UIButton) {
        ProgressHUD.showInfo("暂未开发，敬请期待")
    }
}

extension ACMyDeviceViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        
    }
    
    fileprivate func setupData() {
        
    }
}

extension ACMyDeviceViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        
        return nil
    }
}
