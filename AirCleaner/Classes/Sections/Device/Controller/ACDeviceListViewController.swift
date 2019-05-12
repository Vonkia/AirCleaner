//
//  ACDeviceListViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ACDeviceListViewController: BaseViewController {
    
    //列表
    @IBOutlet weak var tableView: UITableView!
    // 创建ViewModel
    let viewModel = ACDeviceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.tableViewRefreshData { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
    }
}

extension ACDeviceListViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior(rawValue: 2)!
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        viewModel.setConfig(tableView)
    }
    
    fileprivate func setupData() {
        self.tableViewAction()
    }
    
    fileprivate func tableViewAction() {
        //MARK: Rx 绑定tableView点击事件
        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            DLog(indexPath)
        }).disposed(by: bag)
        
        //MARK: Rx 绑定tableView点击model
        tableView.rx.modelSelected(ACDeviceModel.self).subscribe(onNext: { (deviceModel: ACDeviceModel) in
            DLog(deviceModel.num)
        }).disposed(by: bag)
    }
    
    // 下个界面跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ACDeviceConnectViewController,
            let deviceModel = viewModel.selectedModel {
            viewController.deviceModel = deviceModel
        }
    }
}
