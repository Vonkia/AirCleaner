//
//  RequestService.swift
//  AirCleaner
//
//  Created by vonkia on 07/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import Foundation
import Moya
import SwiftHash

/*
 示例地址：http://zhibangfuwu.com/afis/api/common/getCode?phone=13823227110&sign=501DD607EAB7403C0DD79470E60506B4
 前缀 http://zhibangfuwu.com/afis/
 */

//签名代码
private let kSignCode = "MIBOAPP"

enum RequestServiceTemp {
    // MARK: - 公共接口
    case commonGetCode(String) // 获取验证码接口
    case commonUpload(Data) // 文件上传接口
    // MARK: - 用户相关接口
    case accountRegister(String, String, String) // 用户注册接口
    case accountLogin(String, String)  // 用户登录接口
    case accountResetPwd(String, String, String)  // 重置密码接口
    case accountNick(String, String)  // 修改昵称接口
    case accountPortrait(String, String)  // 修改头像接口
}

extension RequestServiceTemp: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL.init(string: "http://zhibangfuwu.com/afis/")!
    }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        // 获取验证码接口
        case .commonGetCode(let phone):
            let params = ["phone": phone]
            return getFullRoute("api/common/getCode", params: params)
        // 文件上传接口
        case .commonUpload(_):
            return "api/common/upload"
        // 用户注册接口
        case .accountRegister(let phone, let password, let code):
            let params = ["phone": phone,
                          "password": password,
                          "code": code]
            return getFullRoute("api/account/register", params: params)
        // 用户登录接口
        case .accountLogin(let phone, let password):
            let params = ["phone": phone,
                          "password": password]
            return getFullRoute("api/account/login", params: params)
        // 重置密码接口
        case .accountResetPwd(let phone, let password, let code):
            let params = ["phone": phone,
                          "password": password,
                          "code": code]
            return getFullRoute("api/account/resetPwd", params: params)
        // 修改昵称接口
        case .accountNick(let nick, let token):
            let params = ["nick": nick,
                          "token": token]
            return getFullRoute("api/account/nick", params: params)
        // 修改头像接口
        case .accountPortrait(let portrait, let token):
            let params = ["portrait": portrait,
                          "token": token]
            return getFullRoute("api/account/portrait", params: params)
        }
    }
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .post
    }
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        // 文件上传接口
        case .commonUpload(let data):
            return .requestData(data)
        default:
            return .requestPlain
        }
    }
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
    /// The headers to be used in the request.
    var headers: [String: String]? {
        return nil
    }
    
    
    //MARK: - Other
    /// 参数签名
    private func getFullRoute(_ route: String, params: [String: Any]) -> String {
        // 示例地址：http://zhibangfuwu.com:8088/afis/api/common/getCode?phone=13823227110&sign=501DD607EAB7403C0DD79470E60506B4
        var paramStr = route
        var signStr = kSignCode
        for (key, value) in params {
            if signStr == kSignCode {
                paramStr += "?\(key)=\(value)"
            } else {
                paramStr += "&\(key)=\(value)"
            }
            signStr += "\(value)"
        }
        paramStr += "&sign=\(MD5(signStr))"
        return paramStr
    }
}
