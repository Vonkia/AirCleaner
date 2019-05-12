//
//  ACAddDeviceViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class ACDeviceAddViewController: BaseViewController {

    /// 是否跳转到首页
    var jumpRoomFrontVc = false
    /// 设备列表
    @IBOutlet weak var deviceView: UIView!
    /// 设备类型
    @IBOutlet weak var deviceTypeFeild: UITextField!
    /// 设备型号
    @IBOutlet weak var deviceMarkerField: UITextField!
    /// 设备序列号
    @IBOutlet weak var deviceNumField: UITextField!
    /// 设备密码
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // 显示设备列表
    @IBAction func showDeviceListAction(_ sender: UIButton) {
        if let window = UIApplication.shared.keyWindow {
            deviceView.frame = window.frame
            window.addSubview(deviceView)
        }
    }
    // 点击蒙版
    @IBAction func deviceViewAction(_ sender: UITapGestureRecognizer) {
        deviceView.removeFromSuperview()
    }
    
    // 点击设备列表
    @IBAction func deviceCellAction(_ sender: UIButton) {
        deviceTypeFeild.text = "净化器"
        deviceView.removeFromSuperview()
    }
    
    // 添加设备
    @IBAction func addDeviceAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if let type = deviceTypeFeild.text,
            let marker = deviceMarkerField.text,
            let num = deviceNumField.text,
            let password = passwordField.text,
            type.count > 0,
            marker.count > 0,
            num.count > 0,
            password.count > 0 {
            
            // 判断设备是否存在
            if StoreManager.shared.airCleanerArr.filter({ $0.num == num }).count > 0 {
                ProgressHUD.showError("已存在此设备信息，不能重复添加!")
                return
            }
            
            // 添加设备
            let deviceModel = ACDeviceModel(num: num, type: type, marker: marker, password: password, isUse: true)
            StoreManager.shared.useAirCleaner = deviceModel
            self.jumpRoomFrontViewController(deviceModel: deviceModel)
        } else {
            ProgressHUD.showError("请输入完整的设备信息")
        }
    }
}

extension ACDeviceAddViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        
    }
    
    fileprivate func setupData() {
        
    }
    
    // 跳转到设备连接界面
    fileprivate func jumpRoomFrontViewController(deviceModel : ACDeviceModel) {
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ACDeviceConnectViewController") as! ACDeviceConnectViewController
        vc.deviceModel = deviceModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
