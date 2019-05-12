//
//  MacroConfig.swift
//  AirCleaner
//
//  Created by vonkia on 2017/10/29.
//  Copyright © 2017年 vonkia. All rights reserved.
//

import UIKit

//MARK: - MODBUS通讯协议
//以下寄存器地址均为十进制描述。可通过主板端的wifi或485口进行通讯。485通讯设定为: 1:8:N:1  38400
enum ModbusProtocol: Int {
    case defaultValue                   = 0 //默认值

    //MARK: 寄存器地址(十进制),以下为主板及附板检测值,仅读(03命令)
    case readSwitchState_1              = 1000 //开关量输入1状态(X1)   1:X1对GND短接  0:未短接
    case readSwitchState_2              = 1001 //开关量输入2状态(X1)   1:X1对GND短接  0:未短接
    case readSwitchState_3              = 1002 //开关量输入3状态(X1)   1:X1对GND短接  0:未短接
    case readSwitchState_4              = 1003 //开关量输入4状态(X1)   1:X1对GND短接  0:未短接
    case readSwitchState_5              = 1004 //开关量输入5状态(X1)   1:X1对GND短接  0:未短接
    case readAnalogValueAD_1            = 1005 //模拟量输入1AD检测值   0~4095
    case readAnalogValueAD_2            = 1006 //模拟量输入2AD检测值   0~4095
    case readAnalogValueAD_3            = 1007 //模拟量输入3AD检测值   0~4095
    //1008~1019 预留
    //1020~1031 此编号为主板唯一编号，每块主板编号均不同（2017.7.25）
    case readHostNumberASCII_1          = 1020 //主机编号第1位(ASCII码)
    case readHostNumberASCII_2          = 1021 //主机编号第2位(ASCII码)
    case readHostNumberASCII_3          = 1022 //主机编号第3位(ASCII码)
    case readHostNumberASCII_4          = 1023 //主机编号第4位(ASCII码)
    case readHostNumberASCII_5          = 1024 //主机编号第5位(ASCII码)
    case readHostNumberASCII_6          = 1025 //主机编号第6位(ASCII码)
    case readHostNumberASCII_7          = 1026 //主机编号第7位(ASCII码)
    case readHostNumberASCII_8          = 1027 //主机编号第8位(ASCII码)
    case readHostNumberASCII_9          = 1028 //主机编号第9位(ASCII码)
    case readHostNumberASCII_10         = 1029 //主机编号第10位(ASCII码)
    case readHostNumberASCII_11         = 1030 //主机编号第11位(ASCII码)
    case readHostNumberASCII_12         = 1031 //主机编号第12位(ASCII码)
    //1032~1099 预留
    case readBoard_1_switchState        = 1100 //附板1的开关机状态  0--off  1--on
    case readBoard_1_fanState           = 1101 //附板1的风机状态  风速开度百分比
    case readBoard_1_pm5                = 1102 //附板1的PM.5值
    case readBoard_1_tempValue          = 1103 //附板1的温度值   此值需除以10,即250表示25.0摄氏度
    case readBoard_1_humiValue          = 1104 //附板1的湿度值
    case readBoard_1_reserve_1          = 1105 //附板1:预留1
    case readBoard_1_reserve_2          = 1106 //附板1:预留2
    case readBoard_1_reserve_3          = 1107 //附板1:预留3
    case readBoard_1_reserve_4          = 1108 //附板1:预留4
    case readBoard_1_reserve_5          = 1109 //附板1:预留5
    case readBoard_2_switchState        = 1110 //附板2的开关机状态  0--off  1--on
    case readBoard_2_fanState           = 1111 //附板2的风机状态  风速开度百分比
    case readBoard_2_pm5                = 1112 //附板2的PM.5值
    case readBoard_2_tempValue          = 1113 //附板2的温度值   此值需除以10,即250表示25.0摄氏度
    case readBoard_2_humiValue          = 1114 //附板2的湿度值
    case readBoard_2_reserve_1          = 1115 //附板2:预留1
    case readBoard_2_reserve_2          = 1116 //附板2:预留2
    case readBoard_2_reserve_3          = 1117 //附板2:预留3
    case readBoard_2_reserve_4          = 1118 //附板2:预留4
    case readBoard_2_reserve_5          = 1119 //附板2:预留5
    //1120~1129 附板3数据,数据说明同上
    //1130~1139 附板4数据,数据说明同上
    //……
    //……
    //1480~1489 附板39数据,数据说明同上
    case readBoard_40_switchState       = 1490 //附板40的开关机状态  0--off  1--on
    case readBoard_40_fanState          = 1491 //附板40的风机状态  风速开度百分比
    case readBoard_40_pm5               = 1492 //附板40的PM.5值
    case readBoard_40_tempValue         = 1493 //附板40的温度值   此值需除以10,即250表示25.0摄氏度
    case readBoard_40_humiValue         = 1494 //附板40的湿度值
    case readBoard_40_reserve_1         = 1495 //附板40:预留1
    case readBoard_40_reserve_2         = 1496 //附板40:预留2
    case readBoard_40_reserve_3         = 1497 //附板40:预留3
    case readBoard_40_reserve_4         = 1498 //附板40:预留4
    case readBoard_40_reserve_5         = 1499 //附板40:预留5
    //MARK: 寄存器地址(十进制),以下为运行控制定,仅写(06/10命令)
    case writeSwitchOutputState_1       = 1800 //主板开关量1输出控制   Y1输出端:0--OFF  1--ON
    case writeSwitchOutputState_2       = 1801 //主板开关量2输出控制   Y1输出端:0--OFF  1--ON
    case writeSwitchOutputState_3       = 1802 //主板开关量3输出控制   Y1输出端:0--OFF  1--ON
    case writeSwitchOutputState_4       = 1803 //主板开关量4输出控制   Y1输出端:0--OFF  1--ON
    case writeSwitchOutputState_5       = 1804 //主板开关量5输出控制   Y1输出端:0--OFF  1--ON
    case writeAnalogOutputValueAD_1     = 1805 //主板:AO1输出百分比(0~100%)
    case writeAnalogOutputValueAD_2     = 1806 //主板:AO2输出百分比(0~100%)
    case writeAnalogOutputValueAD_3     = 1807 //主板:AO3输出百分比(0~100%)
    case writeHostReserve_1             = 1808 //主板:预留1
    case writeHhostReserve_2            = 1809 //主板:预留2
    case writeBoard_1_switchState       = 1810 //附板1:开关机控制  0--关机  1--开机
    case writeBoard_1_fanState          = 1811 //附板1:风机运行控制    0--自动  1--手动低档  2--手动中档  3--手动高档
    case writeBoard_2_switchState       = 1812 //附板2:开关机控制  0--关机  1--开机
    case writeBoard_2_fanState          = 1813 //附板2:风机运行控制    0--自动  1--手动低档  2--手动中档  3--手动高档
    //1814~1815 附板3:数据说明同上
    //……
    //……
    case writeBoard_39_switchState      = 1886 //附板39:开关机控制  0--关机  1--开机
    case writeBoard_39_fanState         = 1887 //附板39:风机运行控制    0--自动  1--手动低档  2--手动中档  3--手动高档
    case writeBoard_40_switchState      = 1888 //附板40:开关机控制  0--关机  1--开机
    case writeBoard_40_fanState         = 1889 //附板40:风机运行控制    0--自动  1--手动低档  2--手动中档  3--手动高档
    //MARK: 寄存器地址(十进制),以下为附板设定值,可读(03命令),也可写(06/10命令)
    case readWriteBoard_1_autoMode      = 2000   //附板1：手动自动模式    风速 0--自动  1--手动低档  2--手动中档  3--手动高档
    case readWriteBoard_1_runMode       = 2001   //附板1：运行模式  0--时间控制  1--传感器信号控制
    case readWriteBoard_1_workDaySetting             = 2002   //附板1：周1~周5 定时开启设定  0--off  1--on
    case readWriteBoard_1_weekendSetting             = 2003   //附板1：周6~周日 定时开启设定  0--off  1--on
    case readWriteBoard_1_workDayOpenHourGroup_1     = 2004   //附板1：周1~周5 开启(时) 第1组
    case readWriteBoard_1_workDayOpenMinuteGroup_1   = 2005   //附板1：周1~周5 开启(分) 第1组
    case readWriteBoard_1_workDayCloseHourGroup_1    = 2006   //附板1：周1~周5 关闭(时) 第1组
    case readWriteBoard_1_workDayCloseMinuteGroup_1  = 2007   //附板1：周1~周5 关闭(分) 第1组
    case readWriteBoard_1_workDayOpenHourGroup_2     = 2008   //附板1：周1~周5 开启(时) 第2组
    case readWriteBoard_1_workDayOpenMinuteGroup_2   = 2009   //附板1：周1~周5 开启(分) 第2组
    case readWriteBoard_1_workDayCloseHourGroup_2    = 2010   //附板1：周1~周5 关闭(时) 第2组
    case readWriteBoard_1_workDayCloseMinuteGroup_2  = 2011   //附板1：周1~周5 关闭(分) 第2组
    case readWriteBoard_1_weekendOpenHourGroup_1     = 2012   //附板1：周六~周日 开启(时) 第1组
    case readWriteBoard_1_weekendOpenMinuteGroup_1   = 2013   //附板1：周六~周日 开启(分) 第1组
    case readWriteBoard_1_weekendCloseHourGroup_1    = 2014   //附板1：周六~周日 关闭(时) 第1组
    case readWriteBoard_1_weekendCloseMinuteGroup_1  = 2015   //附板1：周六~周日 关闭(分) 第1组
    case readWriteBoard_1_weekendOpenHourGroup_2     = 2016   //附板1：周六~周日 开启(时) 第2组
    case readWriteBoard_1_weekendOpenMinuteGroup_2   = 2017   //附板1：周六~周日 开启(分) 第2组
    case readWriteBoard_1_weekendCloseHourGroup_2    = 2018   //附板1：周六~周日 关闭(时) 第2组
    case readWriteBoard_1_weekendCloseMinuteGroup_2  = 2019   //附板1：周六~周日 关闭(分) 第2组
    case readWriteBoard_1_reserve_1                  = 2020   //附板1：预留1
    case readWriteBoard_1_reserve_2                  = 2021   //附板1：预留2
    case readWriteBoard_1_reserve_3                  = 2022   //附板1：预留3
    case readWriteBoard_1_reserve_4                  = 2023   //附板1：预留4
    //2024~2047 附板2: 数据说明同上
    //2048~2071 附板3: 数据说明同上
    //……
    //……
    //2912~2935 附板39: 数据说明同上
    //2936~2959 附板40: 数据说明同上
}


/*******************Enum**************************/
enum SocketConnectStatus: Int8 {
    case unConnected       = 0 //未连接状态
    case connected         = 1 //连接状态
    case closeConnected    = 2 //关闭连接
}


enum SocketMessageType: Int8 {
    case unknow           = 1 // 未知消息类型
}

enum ModbusFunction: UInt8 {
    case read             = 3 //读
    case write            = 6 //写
    case write_dasd       = 10 //
}


/*******************Socket**************************/
let TCP_VersionCode         = "1"             //当前TCP版本(服务器协商,便于服务器版本控制)
let TCP_beatBody            = "beatID"        //心跳标识
let TCP_AutoConnectCount    = 3               //自动重连次数
let TCP_BeatDuration        = 1               //心跳频率
let TCP_MaxBeatMissCount    = 3               //最大心跳丢失数
let TCP_PingUrl             = "http://www.baidu.com" //测试网络
let TCP_Port: UInt16        = 2227            //Port

