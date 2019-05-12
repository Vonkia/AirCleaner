//
//  NSData+CRC16.h
//  AirCleaner
//
//  Created by vonkia on 2017/10/29.
//  Copyright © 2017年 vonkia. All rights reserved.
//

/**
 * http://stackoverflow.com/questions/15140699/nsdata-to-crc-16
 */

#import <Foundation/Foundation.h>

@interface NSData (CRC16)

- (unsigned short)crc16Checksum;

@end
