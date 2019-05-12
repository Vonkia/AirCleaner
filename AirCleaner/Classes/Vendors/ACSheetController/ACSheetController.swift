//
//  ACSheetController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/11.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

// 回调
typealias ACSheetHandle = (Int) -> Void

private let ACSheetCellID = "ACSheetCell"

class ACSheetController: UIViewController {
    
    // 选择回调
    private var sheetHandle: ACSheetHandle?
    // 背景点击回调
    private var backgroundHandle: (() -> Void)?
    // 选项列表
    @IBOutlet weak var sheetTableView: UITableView!
    // 选项列表高度
    @IBOutlet weak var sheetTableViewHeight: NSLayoutConstraint!
    // 标题名
    @IBOutlet weak var titleLabel: UILabel!
    // rx
    lazy var bag = DisposeBag()
    // 列表数据
    private var dataArr: [String]!
    
    public convenience init(title: String,
                            dataArr: [String],
                            sheetAction: ACSheetHandle? = nil,
                            backgroundAction: (() -> Void)? = nil) {
        self.init()
        modalPresentationStyle = .custom
        self.title = title
        self.dataArr = dataArr
        self.sheetHandle = sheetAction
        self.backgroundHandle = backgroundAction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    @IBAction func backgroundAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true) { [weak self] in
            if let handle = self?.backgroundHandle { handle() }
        }
    }
}

extension ACSheetController {
    
    /// 设置UI
    fileprivate func setupUI() {
        if #available(iOS 11.0, *) {
            sheetTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior(rawValue: 2)!
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        titleLabel.text = title
        sheetTableView.tableFooterView = UIView()
        sheetTableViewHeight.constant = 50.0 * CGFloat(dataArr.count)
        sheetTableView.register(UITableViewCell.self, forCellReuseIdentifier: ACSheetCellID)
        
        // let arr1 = (0..<5).map { "\($0)" }
        let variable =  Variable(dataArr!)
        //MARK: Rx 绑定tableView数据
        
        variable.asObservable()
            .bind(to: sheetTableView.rx.items(cellIdentifier: ACSheetCellID, cellType: UITableViewCell.self)){ (row, element, cell) in
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.text = element
            }.disposed(by: bag)
        
        //MARK: Rx 绑定tableView点击事件
        sheetTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                if let handle = self?.sheetHandle { handle(indexPath.row) }
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: bag)
        
        //MARK: Rx 绑定tableView点击model
        sheetTableView.rx.modelSelected(String.self)
            .subscribe(onNext: { (title : String) in
                DLog(title)
            }).disposed(by: bag)
    }
    
    fileprivate func setupData() {
        
    }
}

//extension ACSheetController: UIViewControllerTransitioningDelegate {
//    //改变弹出窗口的Frame
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
//
//        return UIPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//
//}



