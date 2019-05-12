//
//  ACACNavigationController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

class ACNavigationController: UINavigationController ,UIGestureRecognizerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        //侧滑返回
        interactivePopGestureRecognizer?.delegate = self
    }

    /*
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        var title : String?
        if childViewControllers.count > 0 {
            title = "返回"
            if childViewControllers.count == 1 {
                title = childViewControllers.first?.title
            }
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(setHighlightedImg:"navigationbar_back_withtext", title: title, target: self, action: #selector(popVC))            
        }
        super.pushViewController(viewController, animated: animated)
    }

    @objc fileprivate func popVC() {
        popViewController(animated:true)
    }
 */
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return childViewControllers.count != 1
    }
}

//MARK: - 修改状态栏
extension ACNavigationController {
    //https://stackoverflow.com/questions/19022210/preferredstatusbarstyle-isnt-called
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // 修改状态栏的样式为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

