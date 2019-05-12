//
//  ACLoginViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


class ACLoginViewController: BaseViewController {
    
    /// 手机号码
    @IBOutlet weak var phoneField: UITextField!
    /// 密码
    @IBOutlet weak var passwordField: UITextField!
    /// 登录
    @IBOutlet weak var loginBtn: UIButton!
    
    fileprivate let viewModel = ACLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setupUI()
        setupData()
    }
    
    // 登录
    @IBAction func loginAction(_ sender: UIButton) {
        
        viewModel.submitLogin(phone: phoneField.text, password: passwordField.text) { [weak self] in
            
            StoreManager.shared.userName = self?.phoneField.text;    // 账号
            StoreManager.shared.passWord = self?.passwordField.text; // 密码
            if StoreManager.shared.useAirCleaner == nil { //当不存在当前使用的设备时
                ProgressHUD.showInfo("当前无默认设备，请先设置默认设备！")
                self?.jumpDeviceAddViewController()
            } else {
                self?.jumpDeviceFrontViewController()
            }
        }
    }
    
    /// storyboard跳转
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ACDeviceFrontViewController" {
            //使用代码跳转 jumpDeviceAddViewController() or jumpRoomFrontViewController()
            return false
        }
        return true
    }
}

extension ACLoginViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        // phoneField.text = "13823227110"
        // passwordField.text = "111111"
        
        //判断账号的输入是否可用
        let phoneValid:Observable = phoneField.rx.text.orEmpty.map {
            $0.count == 11
        }
        //判断密码的输入是否可用
        let passwordValid:Observable = passwordField.rx.text.orEmpty.map {
            $0.count >= 6
        }
        
        //绑定显示
        // phoneValid.bind(to: phoneField.rx.isEnabled).disposed(by: bag)
        // passwordValid.bind(to: registerButton.rx.isEnabled).disposed(by: bag)
        
        //登录按钮的可用与否
        let loginObserver = Observable
            .combineLatest(phoneValid, passwordValid){(phone, password) in
                phone && password
        }
        
        //绑定按钮
        loginObserver.bind(to: loginBtn.rx.isEnabled).disposed(by: bag)
        loginObserver.subscribe(onNext: { [unowned self] (valid) in
            self.loginBtn.alpha = valid ? 1 : 0.5
        }).disposed(by: bag)
    }
    
    fileprivate func setupData() {
        // 账号
        self.phoneField.text = StoreManager.shared.userName;
        // 密码
        self.passwordField.text = StoreManager.shared.passWord;
    }
    
    // 跳转到增加设备
    fileprivate func jumpDeviceAddViewController() {
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ACDeviceAddViewController") as! ACDeviceAddViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 跳转到设备首页
    fileprivate func jumpDeviceFrontViewController() {
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ACDeviceFrontViewController") as! ACDeviceFrontViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension ACLoginViewController : UITextFieldDelegate {
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
        return true
    }
}

