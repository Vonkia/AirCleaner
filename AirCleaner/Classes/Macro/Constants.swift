//
//  Constants.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

// 判断系统
let IOS7 = Int(UIDevice.current.systemVersion)! >= 7 ? true : false;
let IOS8 = Int(UIDevice.current.systemVersion)! >= 8 ? true : false;
let IOS9 = Int(UIDevice.current.systemVersion)! >= 9 ? true : false;
let IOS11 = Int(UIDevice.current.systemVersion)! >= 11 ? true : false;

// 判断设备
func isX() -> Bool {
    if UIScreen.main.bounds.height == 812 {
        return true
    }
    return false
}


let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
//MARK:NAV高度
let NAVMargin = isX() ? 88 : 64
//MARK:TABBAR高度
let TABBARMargin = isX() ? 83 : 49

// 自定义打印方法
func DLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName):(\(lineNum))-\(message)")
    #endif
}
