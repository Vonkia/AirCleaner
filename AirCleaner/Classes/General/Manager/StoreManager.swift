//
//  StoreManager.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/8.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

class StoreManager {

    /// 单例
    static let shared = StoreManager()
    
    /// 个人信息
    var account: ACAccountModel?
    /// 用户令牌
    var token: String {
        get {
            guard let result = account?.user_token else {
                    return ""
            }
            return result
        }
    }
    /// 账号
    var userName: String? {
        set {
            if newValue == nil { return }
            let obj = SQLCacheModel(key: "userName", content: newValue!)
            SQLiteManager.dataCaches.insertData(object: obj)
        }
        get {
            guard let result = SQLiteManager.dataCaches
                .readData(_key: "userName") as? SQLCacheModel else {
                return nil
            }
            return result.content
        }
    }
    /// 密码
    var passWord: String? {
        set {
            if newValue == nil { return }
            let obj = SQLCacheModel(key: "passWord", content: newValue!)
            SQLiteManager.dataCaches.insertData(object: obj)
        }
        get {
            guard let result = SQLiteManager.dataCaches
            .readData(_key: "passWord") as? SQLCacheModel else {
                return nil
            }
            return result.content
        }
    }
    /// IP
    var tcpHost: String {
        get {
            return ModbusTools.getIPAddress()
        }
    }
    /// 端口
    var tcpPort: String {
        set {
            let obj = SQLCacheModel(key: tcpHost, content: newValue)
            SQLiteManager.dataCaches.insertData(object: obj)
        }
        get {
            guard let result = SQLiteManager.dataCaches
            .readData(_key: tcpHost) as? SQLCacheModel else {
                return String(TCP_Port)
            }
            return result.content
        }
    }
    /// 空气净化器列表
    var airCleanerArr: [ACDeviceModel] {
        set {
            SQLiteManager.deviceCaches.delData()
            SQLiteManager.deviceCaches.insertData(args: newValue)
        }
        get {
            guard let objArr = SQLiteManager.deviceCaches.readData() as? [ACDeviceModel] else { return [ACDeviceModel]() }
            return objArr
        }
    }
    /// 当前使用中的空气净化器
    var useAirCleaner: ACDeviceModel? {
        set {
            //修改设备字段isUse = false
            SQLiteManager.deviceCaches.updateDeviceIsUseField()
            // 重新设置默认设备
            newValue?.isUse = true
            SQLiteManager.deviceCaches.insertData(object: newValue)
        }
        get {
            return SQLiteManager.deviceCaches.getUseDevice()
        }
    }
}
