//
//  AppDelegate.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/18.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        loadLaunchAdVC(launchOptions)
        setupData()
        
        testSQL()
        return true
    }
    
    
    func testSQL() {
        /*
        //读取全部数据
        SQLiteManager.deviceCaches.delData()
        SQLiteManager.dataCaches.delData()
    
        let result10 = SQLiteManager.deviceCaches.readData()
        let result20 = SQLiteManager.dataCaches.readData()
    
        DLog(result10)
        DLog(result20)
        
    
        var arr1 = [ACDeviceModel]()
        var arr2 = [SQLCacheModel]()
    
        for i in 0..<10 {
        let obj1 = ACDeviceModel(num: "\(i + 1)", type: "\(i + 2)", marker: "\(i + 3)",  password: "\(i + 4)", isUse: true)
        arr1.append(obj1)
    
        let obj2 = SQLCacheModel(key: "\(i + 1)", content: "\(i + 100)")
        arr2.append(obj2)
        }
    
        SQLiteManager.deviceCaches.insertData(args: arr1)
        SQLiteManager.dataCaches.insertData(args: arr2)
        
        */
    
        let result1 = SQLiteManager.deviceCaches.readData()
        let result2 = SQLiteManager.dataCaches.readData()
    
        DLog(result1)
        DLog(result2)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //关闭网络监听
        TcpModbusHandler.shareInstance.stopNetworkListen()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //开启网络监听
        TcpModbusHandler.shareInstance.startNetworkListen()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

