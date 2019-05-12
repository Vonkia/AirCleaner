//
//  ACForgotPasswordViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 23/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire

class ACForgotPasswordViewModel: ACRegisterViewMoldel {
    
    /// 提交修改密码
    public func submitAccountResetPwd(phone: String?, password: String?, aginPassword: String?, code: String?, complete: @escaping () -> Swift.Void) {
        
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
        
        requestAccountResetPwd(phone: phone, password: password, code: code, complete: complete)
    }
    
    /// 重置密码接口
    ///
    /// - Parameters:
    ///   - phone:      手机号码
    ///   - password:   密码
    ///   - code:       验证码
    ///   - complete:   完成回调
    public func requestAccountResetPwd(phone: String, password: String, code: String, complete: @escaping () -> Swift.Void) {
        self.provider
            .rx.request(.accountResetPwd(phone, password, code))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                ProgressHUD.showSuccess("修改成功，请使用新密码登录！")
                complete()
            }).disposed(by: self.bag)
    }
}
