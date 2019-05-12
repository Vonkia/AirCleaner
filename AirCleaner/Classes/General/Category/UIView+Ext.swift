//
//  UIView+Ext.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/17.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit
import TTSwitch

public extension UIView{
    
    var x:CGFloat{
        get{
            return self.frame.origin.x
        } set{
            self.frame.origin.x = newValue
        }
    }
    
    var y:CGFloat{
        get{
            return self.frame.origin.y
        }set{
            self.frame.origin.y = newValue
        }
    }
    
    
    var width:CGFloat{
        get{
            return self.frame.size.width
        }set{
            self.frame.size.width = newValue
        }
    }
    
    var height:CGFloat{
        get{
            return self.frame.size.height
        }set{
            self.frame.size.height = newValue
        }
    }
    var size:CGSize{
        get{
            return self.frame.size
        }set{
            self.frame.size = newValue
        }
    }
    
    var centerX:CGFloat{
        get{
            return self.center.x
        }set{
            self.centerX = newValue
        }
    }
    
    var centerY:CGFloat{
        get{
            return self.center.y
        }set{
            self.centerY = newValue
        }
    }
    
    // 关联 SB 和 XIB
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        
        set {
            layer.shadowRadius = newValue
        }
    }
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable public var shadowColor: UIColor? {
        get {
            return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
        }
        
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        
        set {
            layer.zPosition = newValue
        }
    }
}


public extension UITextField{
    @IBInspectable public var xTitleOffset: CGFloat {
        get {
            return self.leftView?.width ?? 0
        }
        
        set {
            let leftview = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.height))
            self.leftViewMode = .always
            self.leftView = leftview
        }
    }
}


public extension UISlider{
    @IBInspectable public var thumbImageName: String {
        get {
            return "circle"
        }
        
        set {
            self.setThumbImage(UIImage(named: newValue), for: .normal)
            self.setThumbImage(UIImage(named: newValue), for: .highlighted)
            self.setMinimumTrackImage(UIImage(named: "d_sel"), for: .normal)
            self.setMaximumTrackImage(UIImage(named: "d_nor"), for: .normal)
        }
    }
}

public extension TTFadeSwitch{
    
    @IBInspectable public var setOn: Bool {
        get {
            return self.isOn
        }
        
        set {
            self.backgroundColor = UIColor.clear
            self.trackImageOn = UIImage(named: "switch_bg")
            self.trackImageOff = UIImage(named: "switch_bg")
            self.thumbImage = UIImage(named: newValue ? "thumb_sel" : "thumb_nor")
            self.thumbImage = UIImage(named: newValue ? "thumb_sel" : "thumb_nor")
            self.setOn(newValue, animated: false)
        }
    }
}


