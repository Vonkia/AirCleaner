//
//  TimerButton.swift
//  AirCleaner
//
//  Created by vonkia on 08/01/2018.
//  Copyright © 2018 vonkia. All rights reserved.
//

import UIKit

// MARK: - 倒计时
extension UIButton {
    
    public func countDown(count: Int){
        // 倒计时开始,禁止点击事件
        isEnabled = false
        
        // 保存当前的背景颜色
        // let defaultColor = self.currentTitleColor
        // 设置倒计时,按钮背景颜色
        // setTitleColor(UIColor.red, for: .normal)
        
        var remainingCount: Int = count {
            willSet {
                setTitle("重新发送(\(newValue))", for: .normal)
                if newValue <= 0 {
                    setTitle("发送验证码", for: .normal)
                }
            }
        }
        
        // 在global线程里创建一个时间源
        let codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler {
            // 返回主线程处理一些事件，更新UI等等
            DispatchQueue.main.async {
                // 每秒计时一次
                remainingCount -= 1
                // 时间到了取消时间源
                if remainingCount <= 0 {
                    // self.setTitleColor(defaultColor, for: .normal)
                    self.isEnabled = true
                    codeTimer.cancel()
                }
            }
        }
        // 启动时间源
        codeTimer.resume()
    }
}
