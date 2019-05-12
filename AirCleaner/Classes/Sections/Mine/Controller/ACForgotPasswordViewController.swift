//
//  ACForgotPasswordViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


class ACForgotPasswordViewController: BaseViewController {
    
    /// 手机号码
    @IBOutlet weak var phoneField: UITextField!
    /// 验证码
    @IBOutlet weak var codeField: UITextField!
    /// 密码
    @IBOutlet weak var passwordField: UITextField!
    /// 重复密码
    @IBOutlet weak var aginPasswordField: UITextField!
    /// 提交
    @IBOutlet weak var submitBtn: UIButton!
    
    fileprivate let viewModel = ACForgotPasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    
    // 获取验证码
    @IBAction func codeAction(_ sender: UIButton) {
        //倒计时
        sender.countDown(count: 60)
        viewModel.getCode(phone: phoneField.text) { (code) in
            let alert = UIAlertController(title: "验证码", message: code, preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 提交
    @IBAction func submitAction(_ sender: UIButton) {
        viewModel.submitAccountResetPwd(phone: phoneField.text,
                                 password: passwordField.text,
                                 aginPassword: aginPasswordField.text,
                                 code: codeField.text) { [weak self] in
                                    self?.navigationController?
                                        .popViewController(animated: true)
        }
    }
}

extension ACForgotPasswordViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        //判断账号的输入是否可用
        let phoneValid:Observable = phoneField.rx.text.orEmpty.map {
            $0.count == 11
        }
        //验证码的输入是否可用
        let codeValid:Observable = codeField.rx.text.orEmpty.map {
            $0.count >= 0
        }
        //判断密码的输入是否可用
        let passwordValid:Observable = passwordField.rx.text.orEmpty.map {
            $0.count >= 6
        }
        let aginPasswordValid:Observable = aginPasswordField.rx.text.orEmpty.map {
            $0.count >= 6
        }
        
        //登录按钮的可用与否
        let loginObserver = Observable
            .combineLatest(phoneValid, codeValid, passwordValid, aginPasswordValid){(phone, code, password, aginPassword) in
                phone && code && password && aginPassword
        }
        
        //绑定按钮
        loginObserver.bind(to: submitBtn.rx.isEnabled).disposed(by: bag)
        loginObserver.subscribe(onNext: { [unowned self] (valid) in
            self.submitBtn.alpha = valid ? 1 : 0.5
        }).disposed(by: bag)
    }
    
    fileprivate func setupData() {
        
    }
}


extension ACForgotPasswordViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 { //点击删除
            return true
        }
        guard let count = textField.text?.count else {
            return true
        }
        if phoneField == textField && count >= 11 {
            return false
        }
        else if codeField == textField && count >= 6 {
            return false
        }
        return true
    }
}

