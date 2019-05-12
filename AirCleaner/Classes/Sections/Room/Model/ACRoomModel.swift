//
//  ACRoomModel.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/3.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import Foundation

class ACRoomModel: NSObject {
    var title: String?
    var type: ModbusProtocol?
    
    //附板1的开关机状态  0--off  1--on
    var switchState: String?
    //附板1的风机状态  风速开度百分比
    var fanState: String?
    //附板1的PM.5值
    var pm5: String?
    //附板1的温度值   此值需除以10,即250表示25.0摄氏度
    var tempValue: String?
    //附板1的湿度值
    var humiValue: String?
    
    public init(title: String? = nil, type: ModbusProtocol? = nil) {
        self.title = title
        self.type = type
    }
}
