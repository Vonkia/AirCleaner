//
//  NSString+Modbus.h
//  AirCleaner
//
//  Created by vonkia on 2017/10/29.
//  Copyright © 2017年 vonkia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Modbus)

/**
 * 得到附加上CRC16 Modbus校验码之后的字符
 */
- (NSString*)withCrc16Modbus;
- (NSData *)toNSData;
- (NSString *)toNSString:(NSData*)data;

@end
