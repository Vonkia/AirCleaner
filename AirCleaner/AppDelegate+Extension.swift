//
//  AppDelegate+Extension.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/1.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension AppDelegate {
    /// 加载广告
    public func loadLaunchAdVC(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        let rootVc: ACNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ACNavigationController
        // let rootVc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        loadRootViewController(rootVc: rootVc)
        return //二选一
        
        if launchOptions != nil {
            // 通过推送等方式启动
            window?.rootViewController = rootVc
        } else {
            //4.加载广告
            let adVC = ZLaunchAdVC(waitTime: 4, rootVC: rootVc)
            adVC.configure({ (buttonConfig, adViewConfig) in
                adViewConfig.adFrame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                adViewConfig.animationType = .crossDissolve
            }).setupImage(Data(), duration: 4, options: .onlyLoad) {
                [weak self] in
                self?.window?.rootViewController = rootVc
            }
            window?.rootViewController = adVC
        }
    }
    
    public func setupData() {
        //设置键盘参数
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        //设置弹框配置
        ProgressHUD.initProgressHUD()
        //开启服务器
        if let port = UInt16(StoreManager.shared.tcpPort) {
            TcpModbusHandler.shareInstance.serverInterruption()
            TcpModbusHandler.shareInstance.startServerHost(port: port)
        }
        //设置导航栏颜色
        UINavigationBar.appearance().tintColor = UIColor.white
        // UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffsetMake(0, 20), for: .default) 在storyboard中设置
    }
    
    fileprivate func loadRootViewController(rootVc: UIViewController) {
        if Utils.isDisplayNewFeatur() {
            window?.rootViewController = ACNewFeaturController(completion: { [weak self] in
                self?.window?.rootViewController = rootVc
            })
            return
        }
        self.window?.rootViewController = rootVc
    }
}
