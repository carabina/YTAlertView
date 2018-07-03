//
//  UIImage+__Ext_Color.h
//
//  Created by songyutao on 14-8-15.
//  Copyright (c) 2014年 YiXin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (__Ext_Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color radius:(CGFloat)radius;

+ (UIImage *)imageHollowWithColor:(UIColor *)color radius:(CGFloat)radius;

- (UIImage *)stretchableImage;

+ (UIImage *)imageWithRadialGradient:(NSArray *)colors size:(CGSize)size;

@end
