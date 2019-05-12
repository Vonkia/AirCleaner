//
//  ACPersonalProfileViewModel.swift
//  AirCleaner
//
//  Created by vonkia on 22/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Alamofire

class ACPersonalProfileViewModel: BaseViewModel {
    
    public func submitAccountInfo(headImg: UIImage?, nick: String?, complete: @escaping () -> Swift.Void) {
        
        guard let img = headImg else {
            if let nick = nick {
                // 提交昵称
                requestAccountNick(nick: nick, token: StoreManager.shared.token) {
                    ProgressHUD.showSuccess("个人资料修改成功")
                    StoreManager.shared.account?.user_nick = nick
                    complete()
                }
            }
            return
        }
        
        // 上传图片
        let data = UIImageJPEGRepresentation(img, 0.5)
        requestCommonUpload(data: data!) { (imgUrl) in
            guard let portrait = imgUrl else {
                ProgressHUD.showSuccess("图片上传失败")
                return
            }
            // 提交图片url
            self.requestAccountPortrait(portrait: portrait, token: StoreManager.shared.token) {
                StoreManager.shared.account?.user_portrait = portrait
                if let nick = nick {
                    // 提交昵称
                    self.requestAccountNick(nick: nick, token: StoreManager.shared.token) {
                        ProgressHUD.showSuccess("个人资料修改成功")
                        StoreManager.shared.account?.user_nick = nick
                        complete()
                    }
                }
            }
        }
    }
    
    
    /// 修改头像接口
    ///
    /// - Parameters:
    ///   - portrait:   头像路径
    ///   - token:      令牌
    ///   - complete:   完成回调
    fileprivate func requestAccountPortrait(portrait: String, token: String, complete: @escaping () -> Swift.Void) {
        self.provider
            .rx.request(.accountPortrait(portrait, token))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                complete()
            }).disposed(by: self.bag)
    }
    
    /// 文件上传接口
    ///
    /// - Parameters:
    ///   - data:       文件数据
    ///   - complete:   完成回调
    fileprivate func requestCommonUpload(data: Data, complete: @escaping (String?) -> Swift.Void) {
        self.provider
            .rx.request(.commonUpload(data))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                if let dict = model.resultDict,
                let files = dict["successFiles"] as? [[String: Any]],
                let file = files.first,
                let imgUrl = file["url"] as? String {
                    complete(imgUrl)
                } else {
                    complete(nil)
                }
            }).disposed(by: self.bag)
    }
    
    /// 修改昵称接口
    ///
    /// - Parameters:
    ///   - nick:       昵称
    ///   - token:      令牌
    ///   - complete:   完成回调
    fileprivate func requestAccountNick(nick: String, token: String, complete: @escaping () -> Swift.Void) {
        self.provider
            .rx.request(.accountNick(nick, token))
            .filterSuccessfulStatusCodes()
            .asObservable()
            .mapJSON()
            .mapObject(type: ResponseModel.self).subscribe(onNext: { (model) in
                complete()
            }).disposed(by: self.bag)
    }
}
