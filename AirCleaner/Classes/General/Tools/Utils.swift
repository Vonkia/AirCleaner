//
//  Utils.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/2.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation

class Utils: NSObject {
    /// 是否显示新特性
    public class func isDisplayNewFeatur() -> Bool {
        let curVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let defVersion = UserDefaults.standard.object(forKey: "VersionKey") as? String
        if curVersion == defVersion {
            return false
        } else {
            UserDefaults.standard.set(curVersion, forKey: "VersionKey")
            return true
        }
    }
    
    public class func appVersion() -> String {
        let bundle = Bundle(for: self)
        guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        return version
    }
}
