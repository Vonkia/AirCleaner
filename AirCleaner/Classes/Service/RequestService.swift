//
//  APIManager.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation
import Moya
import SwiftHash

/*
 示例地址：http://zhibangfuwu.com:8088/afis/api/common/getCode?phone=13823227110&sign=501DD607EAB7403C0DD79470E60506B4
 前缀 http://zhibangfuwu.com:8088/afis
 */

//签名代码
private let kSignCode = "MIBOAPP"
private let kHostURL = "http://zhibangfuwu.com/afis/"

enum RequestService {
    // MARK: - 公共接口
    case commonGetCode(String) // 获取验证码接口
    case commonUpload(Data) // 文件上传接口
    // MARK: - 用户相关接口
    case accountRegister(String, String, String) // 用户注册接口
    case accountLogin(String, String)  // 用户登录接口
    case accountResetPwd(String, String, String)  // 重置密码接口
    case accountNick(String, String)  // 修改昵称接口
    case accountPortrait(String, String)  // 修改头像接口
    
    
    case GetHomeList // 获取首页列表
    case GetHomeDetail(Int)  // 获取详情页
}

extension RequestService: TargetType {
    /// The target's base `URL`.
    var baseURL: URL {
        return URL.init(string: kHostURL)!
    }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .commonGetCode(_):
            return "api/common/getCode"
        case .commonUpload(_):
            return "api/common/upload"
        case .accountRegister(_, _, _):
            return "api/account/register"
        case .accountLogin(_,  _):
            return "api/account/login"
        case .accountResetPwd(_, _, _):
            return "api/account/resetPwd"
        case .accountNick(_, _):
            return "api/account/nick"
        case .accountPortrait(_, _):
            return "api/account/portrait"
            
            
            
        case .GetHomeList: // 不带参数的请求
            return "4/news/latest"
        case .GetHomeDetail(let id):  // 带参数的请求
            return "4/theme/\(id)"
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
        // 获取验证码接口
        case .commonGetCode(let phone):
            var params = [(String, Any)]()
            params.append(("phone", phone))
            return signParameters(params)
        // 文件上传接口
        case .commonUpload(let data):
           let mData = MultipartFormData(provider: .data(data), name: "enctype", fileName: "pictrue.jpg", mimeType: "multipart/form-data")
           return .uploadMultipart([mData])
        // 用户注册接口
        case .accountRegister(let phone, let password, let code):
            var params = [(String, Any)]()
            params.append(("code", code))
            params.append(("password", password))
            params.append(("phone", phone))
            return signParameters(params)
        // 用户登录接口
        case .accountLogin(let phone, let password):
            var params = [(String, Any)]()
            params.append(("password", password))
            params.append(("phone", phone))
            return signParameters(params)
        // 重置密码接口
        case .accountResetPwd(let phone, let password, let code):
            var params = [(String, Any)]()
            params.append(("code", code))
            params.append(("password", password))
            params.append(("phone", phone))
            return signParameters(params)
        // 修改昵称接口
        case .accountNick(let nick, let token):
            var params = [(String, Any)]()
            params.append(("nick", nick))
            params.append(("token", token))
            return signParameters(params)
        // 修改头像接口
        case .accountPortrait(let portrait, let token):
            var params = [(String, Any)]()
            params.append(("portrait", portrait))
            params.append(("token", token))
            return signParameters(params)
            
            
            
        case .GetHomeList: // 不带参数的请求
            return .requestPlain
        case .GetHomeDetail(let id):  // 带参数的请求
            DLog(id)
            // return .requestParameters(parameters: self.parameters, encoding: JSONEncoding)
            return .requestPlain
        }
    }
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
    /// The headers to be used in the request.
    var headers: [String: String]? {
        switch self {
        // 文件上传接口
        case .commonUpload(_):
            return nil //["enctype": "multipart/form-data"]
        default:
            return nil
        }
    }
    
    
    //MARK: - Other
    /// 参数签名
    private func signParameters(_ params: [(String, Any)]) -> Task {
        //http://192.168.1.151:9009/afis/api/common/getCode?phone=13823227110&sign=501DD607EAB7403C0DD79470E60506B4
        var reqParams = [String: Any]()
        var tempStr = kSignCode
        for (key, value) in params {
            reqParams[key] = value
            tempStr.append(String(describing: value))
        }
        tempStr = MD5(tempStr)
        reqParams["sign"] = tempStr
        return Task.requestParameters(parameters: reqParams,
                                      encoding: URLEncoding.default)
    }
}
