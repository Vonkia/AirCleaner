//
//  File.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/4.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation

public extension Date {
    public static func currentTimeStamptSting() -> String {
        return "\(Date().timeIntervalSince1970)"
    }
    
    public static func currentTimeStamptInt() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
    
    public static func formatter(_ formatter: String, dateString: String?) -> Date {
        let dateFormatter = DateFormatter()
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = formatter.count > 0 ? formatter : "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.date(from: dateString ?? "") ?? Date()
    }
    
    public func formatter(_ formatter: String) -> String {
        let dateFormatter = DateFormatter()
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = formatter.count > 0 ? formatter : "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.string(from: self)
    }
}
