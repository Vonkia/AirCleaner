//
//  UIBarButtonItem+Ext.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

extension UIBarButtonItem{

    ///UIBarButtonItem
    ///
    /// - parameter setHighlightedImg: 背景图片
    /// - parameter title:             标题
    /// - parameter target:            target
    /// - parameter action:            action 
    convenience init(setHighlightedImg:String? ,title:String? ,target:Any?,action:Selector) {
        self.init()
        let  button = UIButton(setHighlightImage:setHighlightedImg, title: title, target: target, action: action)
        self.customView = button
    }
}


