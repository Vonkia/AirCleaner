//
//  UILable+Ext.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(text:String,font:CGFloat,textColor:UIColor,maxWidth:CGFloat = 0) {
        self.init()
        self.text = text
        self.font = UIFont.systemFont(ofSize: font)
        self.textColor = textColor
        if maxWidth > 0{
            self.preferredMaxLayoutWidth = maxWidth
            self.numberOfLines = 0
        }
    }
}
