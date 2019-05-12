//
//  ACLoginViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 09/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire

class ACLoginViewModel: BaseViewModel {
    
    /// 提交注册
    public func submitLogin(phone: String?, password: String?, complete: @escaping () -> Swift.Void) {
        
        guard let phone = phone else {
            ProgressHUD.showError("请输入您的手机号码")
            return
        }
        guard phone =~ RegexHelperType.PhoneNum.rawValue else {
            ProgressHUD.showError("您输入的手机号码格式有误")
            return
        }
        
        guard let password = password else {
            ProgressHUD.showError("请设置您的登录密码")
            return
        }
        guard password =~ RegexHelperType.Password.rawValue else {
            ProgressHUD.showError("请输入6到18位密码")
            return
        }
        
        requestAccountLogin(phone: phone, password: password, complete: complete)
    }
    /// 请求登录
    public func requestAccountLogin(phone: String, password: String, complete: @escaping () -> Swift.Void) {
        self.provider
            .rx.request(.accountLogin(phone, password))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ACAccountModel.self).subscribe(onNext: { (model) in
                ProgressHUD.showSuccess("登录成功")
                // 保存用户登录信息
                StoreManager.shared.account = model
                complete()
            }).disposed(by: self.bag)
    }
}
