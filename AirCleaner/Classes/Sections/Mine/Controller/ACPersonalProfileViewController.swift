//
//  ACPersonalProfileViewController.swift
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

class ACPersonalProfileViewController: BaseViewController {
    
    /// 头像
    @IBOutlet weak var iconButton: UIButton!
    /// 昵称
    @IBOutlet weak var niceField: UITextField!
    /// 手机号码
    @IBOutlet weak var phoneLabel: UILabel!

    fileprivate let viewModel = ACPersonalProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // 设置头像
    @IBAction func setupIconAction(_ sender: UIButton) {
        PictureSelector.pictureSelector(withVisible: self, showSheet: true) { [weak self] (image) in
            self?.iconButton.setImage(image, for: .normal)
        }
    }
    
    // 提交
    @IBAction func submitAction(_ sender: UIBarButtonItem) {
        let headImg = self.iconButton.currentImage
        let nice = self.niceField.text
        viewModel.submitAccountInfo(headImg: headImg, nick: nice) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ACPersonalProfileViewController {
    
    /// 设置UI
    fileprivate func setupUI() {
        // 头像
        if let portraitUrl = URL(string: StoreManager.shared.account?.user_portrait ?? "") {
            self.iconButton.kf.setImage(with: ImageResource(downloadURL: portraitUrl), for: .normal)
        }
        /// 昵称
        if let nice = StoreManager.shared.account?.user_nick {
            self.niceField.text = nice
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


extension ACPersonalProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
