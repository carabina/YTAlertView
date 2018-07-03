//
//  YXAlertView.h
//
//  Created by songyutao on 2014-8-20.
//  Copyright (c) 2014年 YiXin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YTAlertViewStyleType)
{
    YTAlertViewStyleTypeDefault     =   0,
    YTAlertViewStyleTypeSecureInput,
    YTAlertViewStyleTypePlainInput,
};

typedef NS_ENUM(NSUInteger, YTAlertViewMessageAlignment)
{
    YTAlertViewMessageAlignmentLeft   =   0,
    YTAlertViewMessageAlignmentCenter,
    YTAlertViewMessageAlignmentRight,
};

@class YTAlertView;

typedef void(^YTAlertBlock)(BOOL cancel, NSInteger buttonIndex, YTAlertView *alert);

@interface YTAlertView : UIView

@property(nonatomic, copy)NSString                  *title;
@property(nonatomic, copy)NSString                  *message;
@property(nonatomic, assign)YTAlertViewStyleType    alertStyleType;

@property(nonatomic)UIEdgeInsets                    contentInset                            UI_APPEARANCE_SELECTOR;//default UIEdgeInsetsMake(8, 8, 8, 8)
@property(nonatomic)YTAlertViewMessageAlignment     messageAlignment                        UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)UIColor           *divideLineColor                                UI_APPEARANCE_SELECTOR;//分割线颜色
@property(nonatomic, copy)UIImage           *backgroundImage                                UI_APPEARANCE_SELECTOR;
//Attribute support NSFontAttributeName and NSForegroundColorAttributeName
@property(nonatomic, copy)NSDictionary      *titleAttributeDictionary                       UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *messageAttributeDictionary                     UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *buttonTitleAttributeDictionary                 UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *buttonTitleDisableAttributeDictionary          UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *buttonTitleHighAttributeDictionary             UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *buttonBackgroundImageAttributeDictionary       UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy)NSDictionary      *cancelButtonBackgroundImageAttributeDictionary UI_APPEARANCE_SELECTOR;//support UIControlState UIControlStateNormal and UIControlStateHighlighted
@property(nonatomic, copy)NSDictionary      *cancelButtonTitleAttributeDictionary           UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong)UIView          *customView;
@property(nonatomic, assign)BOOL             contentSupportScroll;//控制contentview是否支持滚动，默认YES

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSInteger)setCancelButtonWithTitle:(NSString *)title;
- (UITextField *)textField;
- (UIButton *)buttongForIndex:(NSInteger)index;//index从0开始，不能为负数

- (void)show:(YTAlertBlock)yxAlertBlock;
- (void)dismiss;

+ (CGFloat)alertViewWidth;

+ (id)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelButtonTitle otherTitle:(NSString *)otherButtonTitle completion:(YTAlertBlock)completion;

+ (void)dismissAlert;

+ (void)dismissAll;

@end

