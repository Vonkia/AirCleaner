//
//  MacroColor.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

let THEMECOLOR = UIColor.yellow

func RandomColor() -> UIColor{
    let r = CGFloat(arc4random()%256)
    let g = CGFloat(arc4random()%256)
    let b = CGFloat(arc4random()%256)
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
}

func RGBCOLOR(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ alpha:CGFloat = 1.0) -> UIColor{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: alpha)
}

// MARK: - RGB设置颜色
func HEXCOLOR(_ rgbValue: Int) -> UIColor {
    return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16)/255.0, green: (CGFloat)((rgbValue & 0xFF00) >> 8)/255.0, blue: (CGFloat)(rgbValue & 0xFF)/255.0, alpha: 1.0)
}
