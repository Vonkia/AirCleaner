//
//  BaseViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/6.
//  Copyright © 2018年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire
import MJRefresh

enum ACRefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case noMoreData
}

public func defaultAlamofireManager() -> Manager {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    let policies: [String: ServerTrustPolicy] = [
        "ap.grtstar.cn": .disableEvaluation
    ]
    let manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))
    manager.startRequestsImmediately = false
    return manager
}

public func endpointMapping<Target: TargetType>(target: Target) -> Endpoint<Target> {
    DLog("🚀🚀 \(target.baseURL)\(target.path) \n\(target.task)")
    return MoyaProvider.defaultEndpointMapping(for: target)
}


class BaseViewModel: NSObject {
    // 显示销毁rxswift
    let bag : DisposeBag = DisposeBag()
    /// 网络请求
    let provider = MoyaProvider<RequestService>(endpointClosure: endpointMapping, manager: defaultAlamofireManager(), plugins: [RequestPlugin(), netWorkActivityPlugin])
    /// 刷新状态
    let refreshStateObserable = Variable<ACRefreshStatus>(.none)
    /// 网络请求观察者
    let requestNewDataCommond =  PublishSubject<Bool>()
    /// 分页标签
    var pageIndex = Int()
}
