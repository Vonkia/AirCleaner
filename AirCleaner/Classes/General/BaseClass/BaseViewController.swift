//
//  BaseViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    // 显示销毁rxswift
    let bag : DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DLog("🌹当前控制器：\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.endEditing(true)
    }
    
    deinit {
        DLog("🍵移除控制器：\(self)")
    }
}


//MARK: - 修改状态栏
extension BaseViewController {
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // 修改状态栏的样式为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
