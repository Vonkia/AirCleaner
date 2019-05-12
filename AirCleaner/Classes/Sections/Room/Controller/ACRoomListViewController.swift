//
//  ACSearchViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/3.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh


class ACRoomListViewController: BaseViewController {
    
    //列表
    @IBOutlet weak var tableView: UITableView!
    // 创建ViewModel
    let viewModel = ACRoomViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
}

extension ACRoomListViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        if #available(iOS 11.0, *) {
             tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior(rawValue: 2)!
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        viewModel.setConfig(tableView)
        
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.viewModel.refreshRoomData()
        })
        tableView.mj_header.beginRefreshing()
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
        tableView.rx.modelSelected(ACRoomModel.self).subscribe(onNext: { (searchModel : ACRoomModel) in
            DLog(searchModel.title)
        }).disposed(by: bag)
    }
    
    // 下个界面跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ACRoomHomeViewController,
            let deviceModel = viewModel.selectedModel {
            viewController.title = deviceModel.title
            viewController.modbusType = deviceModel.type
        }
    }
}
