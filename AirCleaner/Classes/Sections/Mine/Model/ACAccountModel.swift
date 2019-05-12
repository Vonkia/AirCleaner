//
//  ACAccountModel.swift
//  AirCleaner
//
//  Created by vonkia on 23/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import Foundation
import ObjectMapper

class ACAccountModel: Mappable {
    
    /// 登录密码
    var log_pwd: String?
    /// 用户头像
    var user_portrait: String?
    /// 手机号码
    var phone: String?
    /// 用户编号
    var id: String?
    /// 用户令牌
    var user_token: String?
    /// 用户昵称
    var user_nick: String?
    /// 用户状态
    var user_state: String?
    
    //  接下来的两个方法是必须要实现的
    required init?(map: Map) { }
    
    public func mapping(map: Map) {
        log_pwd <- map["log_pwd"]
        user_portrait <- map["user_portrait"]
        phone <- map["phone"]
        id <- map["id"]
        user_token <- map["user_token"]
        user_nick <- map["user_nick"]
        user_state <- map["user_state"]
    }
}
