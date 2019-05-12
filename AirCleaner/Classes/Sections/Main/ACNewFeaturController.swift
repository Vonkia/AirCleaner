//
//  ACNewFeaturController.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/2.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

class ACNewFeaturController: UIViewController {
    
    var completion: (()->())?
    lazy var backScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        self.view.addSubview(scrollView)
        return scrollView
    }()
    
    /// 初始化方法
    convenience init(completion: @escaping () -> ()) {
        self.init()
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iconNameArr = ["bj1", "bj2", "bj3"]
        var iconFrame = backScrollView.bounds
        for i in 0..<iconNameArr.count {
            let iconName = iconNameArr[i]
            iconFrame.origin.x = CGFloat(i) * iconFrame.size.width
            
            let imageView = UIImageView(frame: iconFrame)
            imageView.image = UIImage(named: iconName)
            imageView.isUserInteractionEnabled = true
            backScrollView.addSubview(imageView)
            //设置最后一张图点击、滑动
            if i == iconNameArr.count - 1 {
                let tap = UITapGestureRecognizer(target: self, action: #selector(goInRootVC))
                let swip = UISwipeGestureRecognizer(target: self, action: #selector(goInRootVC))
                swip.direction = .left
                imageView.addGestureRecognizer(tap)
                imageView.addGestureRecognizer(swip)
            }
        }
        backScrollView.contentSize = CGSize(width: backScrollView.size.width * CGFloat(iconNameArr.count), height: 0)
    }
    
    @objc func goInRootVC() {
        if completion != nil { completion!() }
    }
}
