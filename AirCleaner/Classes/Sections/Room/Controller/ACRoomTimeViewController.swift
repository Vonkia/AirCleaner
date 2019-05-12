//
//  ACRoomTimeViewController.swift
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


class ACRoomTimeViewController: BaseViewController {
    
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
}

extension ACRoomTimeViewController {

    /// 设置UI
    fileprivate func setupUI() {
        
    }
    
    fileprivate func setupData() {
        DLog(ModbusTools.getIPAddress())
        
        // iwevon 开启服务器
        tcpModbus.delegate = self
    }
}

extension ACRoomTimeViewController: TcpModbusHandlerDelegate {
    
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        
        return nil
    }
}

