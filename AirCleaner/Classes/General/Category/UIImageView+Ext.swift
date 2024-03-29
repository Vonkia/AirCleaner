//
//  UIImageView+Ext.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView{

    /// 快速创建 imageView
    ///
    /// - parameter imgName:  图片名字
    ///
    /// - returns:
    convenience init(imgName: String) {
        self.init(image: UIImage(named:imgName))
    }
    
    
    ///
    /// - parameter withUrlString:      图片的 urlString
    /// - parameter placeholderImgName:  默认图片的名字
    func LL_setImage(withUrlString: String?, placeholderImgName: String?){
        // 获取图片的 url
        let url = URL(string: withUrlString ?? "")
        // 判断他是否为 nil
        guard let u = url else {
            return
        }
        self.kf.setImage(with: u, placeholder: UIImage(named: placeholderImgName ?? ""), options: nil, progressBlock: nil, completionHandler: nil)
        
    }



}
