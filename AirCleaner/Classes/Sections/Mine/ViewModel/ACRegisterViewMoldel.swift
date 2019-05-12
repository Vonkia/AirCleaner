//
//  ACRegisterViewMoldel.swift
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

class ACRegisterViewMoldel: BaseViewModel {
    
    /// 获取验证码
    public func getCode(phone: String?, complete: @escaping (String) -> Swift.Void) {
        
        guard let phone = phone else {
            ProgressHUD.showError("请输入您的手机号码")
            return
        }
        guard phone =~ RegexHelperType.PhoneNum.rawValue else {
            ProgressHUD.showError("您输入的手机号码格式有误")
            return
        }
        
        requestCommonGetCode(phone: phone, complete: complete)
    }
    
    /// 请求验证码
    public func requestCommonGetCode(phone: String, complete: @escaping (String) -> Swift.Void) {
        self.provider
            .rx.request(.commonGetCode(phone))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                complete(model.result ?? "请重新获取验证码")
            }).disposed(by: self.bag)
    }
    
    /// 提交注册
    public func submitRegister(phone: String?, password: String?, aginPassword: String?, code: String?, complete: @escaping () -> Swift.Void) {
        
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
        
        guard let aginPassword = aginPassword else {
            ProgressHUD.showError("请确认您的登录密码")
            return
        }
        guard password == aginPassword else {
            ProgressHUD.showError("您输入的确认密码有误")
            return
        }
        
        guard let code = code else {
            ProgressHUD.showError("请输入您收到的验证码")
            return
        }
        guard code =~ RegexHelperType.CodeNum.rawValue else {
            ProgressHUD.showError("您输入的验证码有误")
            return
        }
        
        requestAccountRegister(phone: phone, password: password, code: code, complete: complete)
    }
    /// 请求注册
    public func requestAccountRegister(phone: String, password: String, code: String, complete: @escaping () -> Swift.Void) {
        self.provider
            .rx.request(.accountRegister(phone, password, code))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                ProgressHUD.showSuccess("注册成功")
                complete()
            }).disposed(by: self.bag)
    }
}

