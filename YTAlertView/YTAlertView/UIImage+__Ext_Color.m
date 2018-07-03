//
//  UIImage+__Ext_Color.m
//
//  Created by songyutao on 14-8-15.
//  Copyright (c) 2014年 YiXin. All rights reserved.
//

#import "UIImage+__Ext_Color.h"

#define KCreateImageSize    CGSizeMake(10, 10)

@implementation UIImage (__Ext_Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color radius:0];
}

+ (UIImage *)imageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    return [UIImage imageWithColor:color radius:radius size:KCreateImageSize fill:YES];
}

+ (UIImage *)imageHollowWithColor:(UIColor *)color radius:(CGFloat)radius
{
    return [UIImage imageWithColor:color radius:radius size:KCreateImageSize fill:NO];
}

+ (UIImage *)imageWithColor:(UIColor *)color radius:(CGFloat)radius size:(CGSize)size fill:(BOOL)fill
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];

    UIGraphicsBeginImageContextWithOptions((CGSizeMake(path.bounds.origin.x  + path.bounds.size.width, path.bounds.origin.y + path.bounds.size.height)), NO, .0);
    
    [color set];
    [color setStroke];
    [path addClip];
    [path setLineWidth:2.0f];
    [path stroke];
    
    if (fill)
    {
        [path fill];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image stretchableImage];
}

- (UIImage *)stretchableImage
{
    CGSize size = self.size;
    
    return [self stretchableImageWithLeftCapWidth:size.width/2 topCapHeight:size.height/2];
}

+ (UIImage *)imageWithRadialGradient:(NSArray *)colors size:(CGSize)size
{
    CGPoint center = CGPointMake(size.width * 0.5, size.height * 0.5);
    CGFloat innerRadius = 0;
    CGFloat outerRadius = sqrtf(size.width * size.width + size.height * size.height) * 0.5;
    
    BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(size, opaque, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const size_t locationCount = 2;
    CGFloat locations[locationCount] = { 0.0, 1.0 };
    
    NSInteger numberComponents = 0;
    CGFloat colorComponents[colors.count*4];
    for (int i=0; i<colors.count; i++)
    {
        UIColor *color = [colors objectAtIndex:i];
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        numberComponents = CGColorGetNumberOfComponents(color.CGColor);
        
        if (numberComponents == 4)
        {
            colorComponents[i*4+0] = components[0];
            colorComponents[i*4+1] = components[1];
            colorComponents[i*4+2] = components[2];
            colorComponents[i*4+3] = components[3];
        }
        else if (numberComponents == 2)
        {
            colorComponents[i*4+0] = components[0];
            colorComponents[i*4+1] = components[0];
            colorComponents[i*4+2] = components[0];
            colorComponents[i*4+3] = components[1];
        }
        
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colorComponents, locations, locationCount);
    
    CGContextDrawRadialGradient(context, gradient, center, innerRadius, center, outerRadius, 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
    
    return image;
}

@end
