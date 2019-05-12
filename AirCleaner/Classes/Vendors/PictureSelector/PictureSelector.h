//
//  PictureSelector.h
//  PictureSelector
//
//  Created by iwevon on 2017/8/13.
//  Copyright © 2017年 vonkia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureSelector : NSObject

/// 单选
+ (void)pictureSelectorWithVisible:(UIViewController *)viewController showSheet:(BOOL)showSheet singleSelectPhotoFinish:(void(^)(UIImage *picture))finishBlock;

/// 多选
+ (void)pictureSelectorWithVisible:(UIViewController *)viewController maxCount:(NSUInteger)maxCount multiSelectPhotoFinish:(void(^)(NSArray <UIImage *>*pictures))finishBlock;

@end
