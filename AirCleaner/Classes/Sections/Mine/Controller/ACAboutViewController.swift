//
//  ACAboutViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class ACAboutViewController: BaseViewController {
    
    /// 版本号
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
}

extension ACAboutViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        self.versionLabel.text = "当前版本号：\(Utils.appVersion())"
    }
    
    fileprivate func setupData() {
    }
}
