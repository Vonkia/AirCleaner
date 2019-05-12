//
//  RequestPlugin.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation
import Moya
import Result


let netWorkActivityPlugin = NetworkActivityPlugin { (change, target) in
    switch(change){
    case .ended:
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    case .began:
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

 public final class RequestPlugin: PluginType {
    /// Called immediately before a request is sent over the network (or stubbed).
    public func willSend(_ request: RequestType, target: TargetType) {
        ProgressHUD.showLoading()
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {                
        switch result {
            case .success(let response):
                ProgressHUD.dismissHUD(1.0)
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data,                                                                     options:.allowFragments)
                    DLog(json)
                } catch {
                    DLog("请求网络失败 - \(error)")
                }
            case .failure:
                ProgressHUD.showError("请求加载失败")
                break
        }
    }
}
