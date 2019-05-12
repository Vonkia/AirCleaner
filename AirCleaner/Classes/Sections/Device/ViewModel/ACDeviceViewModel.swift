//
//  ACDeviceViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/16.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

private let ACDeviceCellID = "ACDeviceCell"

class ACDeviceViewModel: NSObject {
    
    //tcpModbus
    let tcpModbus: TcpModbusHandler = TcpModbusHandler.shareInstance
    let bag : DisposeBag = DisposeBag()
    var modelObserable = Variable<[ACDeviceModel]> ([])
    var selectedModel: ACDeviceModel?
    
    public func setConfig(_ tableView: UITableView) {
        // 设置代理
        tcpModbus.delegate = self
        //MARK: Rx 绑定tableView数据
        modelObserable.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: ACDeviceCellID, cellType: ACDeviceCell.self)){ [weak self] row , cellModel , cell in
                cell.cellModel = cellModel
                cell.intoCallBack = { (model) in
                    self?.selectedModel = model
                }
            }.disposed(by: bag)
    }
    
    public func tableViewRefreshData(complete: (() -> Void)? = nil) {
        let modelArr = StoreManager.shared.airCleanerArr
        self.modelObserable.value = modelArr
        if modelArr.count == 0, complete != nil {
            ProgressHUD.showError("暂无设备，请先添加设备!")
            complete?()
        }
    }
}

extension ACDeviceViewModel: TcpModbusHandlerDelegate {
    //接收消息代理
    func didReceive(message: [String], type: ModbusProtocol) -> ModbusProtocol? {
        return nil
    }
    
    //设备连接状态改变
    func deviceConnect(didStatusChange deviceArray: [ACDeviceModel]) {
        DLog(deviceArray)
        self.modelObserable.value = deviceArray
    }
}
