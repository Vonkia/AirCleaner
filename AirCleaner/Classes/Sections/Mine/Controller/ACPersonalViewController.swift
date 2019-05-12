//
//  ACPersonalViewController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/5.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Kingfisher

class ACPersonalViewController: BaseViewController {
    
    /// 头像
    @IBOutlet weak var iconButton: UIButton!
    /// 昵称
    @IBOutlet weak var niceLabel: UILabel!
    /// 手机号码
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setupData()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension ACPersonalViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        // 头像
        if let portraitUrl = URL(string: StoreManager.shared.account?.user_portrait ?? "") {
            self.iconButton.kf.setImage(with: ImageResource(downloadURL: portraitUrl), for: .normal)
        }
        /// 昵称
        if let nick = StoreManager.shared.account?.user_nick {
            self.niceLabel.text = nick
            self.niceLabel.textColor = UIColor.black
        } else {
            self.niceLabel.text = "请设置昵称"
            self.niceLabel.textColor = UIColor.gray
        }
        
        /// 手机号码
        guard let phone = StoreManager.shared.account?.phone else {
            return
        }
        let startIndex = phone.index(phone.startIndex, offsetBy: 3)
        let endIndex = phone.index(phone.startIndex, offsetBy: 8)
        self.phoneLabel.text = phone.replacingCharacters(in: startIndex...endIndex, with: "******")
    }
    
    fileprivate func setupData() {
        
    }
}
