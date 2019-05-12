//
//  ModelExtension.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation

import RxSwift
import Moya
import ObjectMapper


extension Observable {

    func mapObject<T:Mappable>(type: T.Type) -> Observable<T> {
        return self.map { response in
            guard let resModel = Mapper<ResponseModel>().map(JSONObject: response) else {
                // Json解析错误
                throw RxSwiftMoyaError.parseJSONError
            }
            if resModel.code == 200 {
                // 返回数据结果
                if type == ResponseModel.self || resModel.result != nil {
                    return resModel as! T
                } else {
                    return Mapper<T>().map(JSONObject: resModel.resultDict ?? "")!
                }
            } else {
                if let errorMsg = resModel.msg {
                    // 显示错误提示
                    ProgressHUD.showError(errorMsg)
                }
                // 抛出错误
                throw RxSwiftMoyaError.otherError
            }
        }
    }
        
    func mapArray<T: Mappable>(type: T.Type) -> Observable<[T]> {
        return self.map { response in
            //if response is an array of dictionaries, then use ObjectMapper to map the dictionary
            //if not, throw an error
            guard let array = response as? [Any] else {
                throw RxSwiftMoyaError.parseJSONError
            }
            guard let dicts = array as? [[String: Any]] else {
                throw RxSwiftMoyaError.parseJSONError
            }
            return Mapper<T>().mapArray(JSONArray: dicts)
        }
    }
}

enum RxSwiftMoyaError: Swift.Error {
    case parseJSONError
    case otherError
    case requestError(String?)
}

extension Swift.Error {
    var value: String {
        guard let tempError = self as? RxSwiftMoyaError else {
            return ""
        }
        switch tempError {
        case .parseJSONError:
            return "Json解析错误"
        case .otherError:
            return "其它错误"
        case .requestError(let errorMsg):
            return errorMsg ?? "请求错误"
        }
    }
}

// 请求返回model
public class ResponseModel: Mappable {
    var result: String?
    var resultDict: [String: Any]?
    var code: Int?
    var msg: String?
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        result <- map["result"]
        resultDict <- map["result"]
        code <- map["code"]
        msg <- map["msg"]
    }
}

