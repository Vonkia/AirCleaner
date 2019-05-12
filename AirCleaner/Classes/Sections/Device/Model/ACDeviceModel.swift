//
//  ACDeviceModel.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/10.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation

class ACDeviceModel: NSObject {
    
    /// 设备序列号【唯一】
    var num: String
    /// 设备类型
    var type: String
    /// 设备型号
    var marker: String
    /// 设备密码
    var password: String
    /// 是否是当前使用的设备
    var isUse: Bool
    
    public init(num: String, type: String, marker: String, password: String, isUse: Bool) {
        self.type = type
        self.marker = marker
        self.num = num
        self.password = password
        self.isUse = isUse
    }
    
    // 创建临时的model
    public init(tempNum: String) {
        self.type = tempNum
        self.marker = tempNum
        self.num = tempNum
        self.password = tempNum
        self.isUse = false
    }
    
}
