//
//  YTAlertView.m
//
//  Created by songyutao on 2014-8-20.
//  Copyright (c) 2014年 YiXin. All rights reserved.
//

#import "YTAlertView.h"
#import "UIImage+__Ext_Color.h"

static const CGFloat KAlertViewMinHeight         = 100;
static const CGFloat KTitleLabelBottomMargin     = 8;
static const CGFloat KMessageLabelBottomMargin   = 16;
static const CGFloat KAlertButtonDefaultHeight   = 44;
static const CGFloat KTextFieldHeight            = 30;
static const CGFloat KCancelButtonIndex          = 0;

@interface YTAlertView ()

@property(nonatomic, strong)UILabel                 *titleLabel;
@property(nonatomic, strong)UILabel                 *messageLabel;
@property(nonatomic, strong)UITextField             *textField;
@property(nonatomic, strong)UIImageView             *backgroundView;
@property(nonatomic, strong)UIImageView             *markView;
@property(nonatomic, strong)UIButton                *cancelButton;
@property(nonatomic, strong)NSMutableArray          *otherButtons;
@property(nonatomic, strong)UIScrollView            *contentView;

@property(nonatomic, strong)NSMutableArray          *lineArray;

@property(nonatomic, copy)YTAlertBlock               yxAlertBlock;

@end

@implementation YTAlertView

+ (UIWindow *)alertWindow
{
    static UIWindow *alertWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.windowLevel = UIWindowLevelAlert;
    });
    return alertWindow;
}

+ (NSMutableArray *)YTAlertViewArray
{
    static NSMutableArray *YTAlertViewArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YTAlertViewArray = [[NSMutableArray alloc] init];
    });
    return YTAlertViewArray;
}

+ (void)load
{
    static CGFloat defaultBgColor = 240/255.0;
    static CGFloat defaultHighButtonColor = 220/255.0;
    
    UIImage *image = [UIImage imageWithColor:[UIColor colorWithWhite:defaultBgColor alpha:1.0]];
    [[self appearance] setBackgroundImage:image];
    
    [[self appearance] setContentInset:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    [[self appearance] setDivideLineColor:[UIColor colorWithWhite:164/255.0 alpha:1.0f]];
    
    [[self appearance] setMessageAlignment:YTAlertViewMessageAlignmentCenter];
    
    [[self appearance] setTitleAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont boldSystemFontOfSize:17],NSFontAttributeName,
                                                    [UIColor blackColor], NSForegroundColorAttributeName,nil]];
    
    [[self appearance] setMessageAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont systemFontOfSize:15],NSFontAttributeName,
                                                      [UIColor blackColor], NSForegroundColorAttributeName,nil]];
    
    [[self appearance] setButtonTitleAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont boldSystemFontOfSize:16], NSFontAttributeName,
                                                          [UIColor colorWithRed:0 green:91/255.0 blue:1.0 alpha:1.0f], NSForegroundColorAttributeName,nil]];
    
    [[self appearance] setButtonTitleHighAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIFont boldSystemFontOfSize:16],NSFontAttributeName,
                                                              [UIColor colorWithRed:0 green:91/255.0 blue:1.0 alpha:1.0f], NSForegroundColorAttributeName,nil]];
    
    [[self appearance] setButtonTitleDisableAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIFont boldSystemFontOfSize:16],NSFontAttributeName,
                                                                 [UIColor colorWithRed:135/255.0 green:135/255.0 blue:135/255 alpha:1.0f], NSForegroundColorAttributeName,nil]];
    
    [[self appearance] setButtonBackgroundImageAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIImage imageWithColor:[UIColor colorWithWhite:defaultBgColor alpha:1.0]],
                                                                    [NSNumber numberWithInt:UIControlStateNormal],
                                                                    [UIImage imageWithColor:[UIColor colorWithWhite:defaultHighButtonColor alpha:1.0]],
                                                                    [NSNumber numberWithInt:UIControlStateHighlighted],nil]];
    
    [[self appearance] setCancelButtonBackgroundImageAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                          [UIImage imageWithColor:[UIColor colorWithWhite:defaultBgColor alpha:1.0]],
                                                                          [NSNumber numberWithInt:UIControlStateNormal],
                                                                          [UIImage imageWithColor:[UIColor colorWithWhite:defaultHighButtonColor alpha:1.0]],
                                                                          [NSNumber numberWithInt:UIControlStateHighlighted],nil]];
    
    [[self appearance] setCancelButtonTitleAttributeDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont systemFontOfSize:16], NSFontAttributeName,
                                                                [UIColor colorWithRed:0 green:91/255.0 blue:1.0 alpha:1.0f], NSForegroundColorAttributeName,nil]];
    
}

+ (CGFloat)alertViewWidth
{
    return MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)/5*4;
}

+ (id)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelButtonTitle otherTitle:(NSString *)otherButtonTitle completion:(YTAlertBlock)completion
{
    YTAlertView *alert = [[YTAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
    [alert show:completion];
    
    return alert;
}

+ (void)dismissAlert
{
    YTAlertView *alert = [[YTAlertView YTAlertViewArray] firstObject];
    [alert dismiss];
}

+ (void)dismissAll
{
    [[YTAlertView YTAlertViewArray] removeAllObjects];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(0, 0, [YTAlertView alertViewWidth], KAlertViewMinHeight);
    self = [super initWithFrame:rect];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIScrollView alloc] init];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = YES;
        [self addSubview:_contentView];
        
        self.lineArray = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_keyboardWillHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (self)
    {
        _alertStyleType = YTAlertViewStyleTypeDefault;
        
        _title = title;
        
        _message = message;
        
        [self setCancelButtonWithTitle:cancelButtonTitle];
        
        if (otherButtonTitles != nil)
        {
            [self addButtonWithTitle:otherButtonTitles];
            
            va_list argPtr;
            va_start(argPtr, otherButtonTitles);
            
            NSString *nextButtonTitle = va_arg(argPtr, NSString*);
            while (nextButtonTitle != nil)
            {
                [self addButtonWithTitle:nextButtonTitle];
                
                nextButtonTitle = va_arg(argPtr, NSString *);
            }
            va_end(argPtr);
        }
    }
    return self;
}

- (CGRect)layoutContentView:(CGRect)rect
{
    CGRect outRect = rect;
    CGRect contentRect = CGRectMake(0, 0, outRect.size.width, MAXFLOAT);
    if (self.message)
    {
        if (!self.messageLabel)
        {
            self.messageLabel = [self _addTitleLabel:self.message];
            [self.contentView addSubview:self.messageLabel];
        }
        
        if (YTAlertViewMessageAlignmentLeft == self.messageAlignment)
        {
            self.messageLabel.textAlignment = NSTextAlignmentLeft;
        }
        else if(YTAlertViewMessageAlignmentRight == self.messageAlignment)
        {
            self.messageLabel.textAlignment = NSTextAlignmentRight;
        }
        
        contentRect = [self _layoutLabel:self.messageLabel labelText:self.message rect:contentRect attribute:self.messageAttributeDictionary];
        contentRect.origin.y += KMessageLabelBottomMargin;
    }
    
    if (self.alertStyleType != YTAlertViewStyleTypeDefault)
    {
        contentRect = [self _layoutTextField:contentRect];
        contentRect.origin.y += KMessageLabelBottomMargin;
    }
    
    if (self.customView)
    {
        self.customView.frame = CGRectMake(0, contentRect.origin.y, self.customView.frame.size.width, self.customView.frame.size.height);
        
        contentRect.origin.y = CGRectGetMaxY(self.customView.frame) + self.contentInset.bottom;
    }
    
    CGFloat height = contentRect.origin.y > [UIScreen mainScreen].bounds.size.height/3*2 ? [UIScreen mainScreen].bounds.size.height/3*2 : contentRect.origin.y;
    
    self.contentView.frame = CGRectMake(outRect.origin.x, outRect.origin.y, contentRect.size.width, height);
    self.contentView.contentSize = CGSizeMake(contentRect.size.width, contentRect.origin.y);
    
    outRect.origin.y += height;
    return outRect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView *lineView in self.lineArray)
    {
        [lineView removeFromSuperview];
    }
    [self.lineArray removeAllObjects];
    
    CGRect contentRect = self.bounds;
    
    contentRect = UIEdgeInsetsInsetRect(contentRect, self.contentInset);
    contentRect.size.height = FLT_MAX;
    
    if (self.title && !self.titleLabel)
    {
        self.titleLabel = [self _addTitleLabel:self.title];
        [self addSubview:self.titleLabel];
    }
    
    if (self.title)
    {
        contentRect = [self _layoutLabel:self.titleLabel labelText:self.title rect:contentRect attribute:self.titleAttributeDictionary];
        contentRect.origin.y += KTitleLabelBottomMargin;
    }
    
    contentRect = [self layoutContentView:contentRect];
    
    contentRect = [self _layoutButton:contentRect];
    
    self.bounds = CGRectMake(0, 0, self.bounds.size.width, contentRect.origin.y);
    
    if (!self.backgroundView)
    {
        self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:self.backgroundView atIndex:0];
    }
    self.backgroundView.image = self.backgroundImage;
    self.backgroundView.frame = self.bounds;
    
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    if (!self.otherButtons)
    {
        self.otherButtons = [NSMutableArray array];
    }
    
    NSInteger index = self.otherButtons.count;
    
    UIButton *button = [self _buttonWithTitle:title];
    
    [self.otherButtons addObject:button];
    
    [self addSubview:button];
    
    return index;
}

- (void)setCustomView:(UIView *)customView
{
    [_customView removeFromSuperview];
    
    _customView = customView;
    
    [self.contentView addSubview:_customView];
}

- (void)setContentSupportScroll:(BOOL)contentSupportScroll
{
    _contentSupportScroll = contentSupportScroll;
    
    self.contentView.scrollEnabled = contentSupportScroll;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title
{
    if (title)
    {
        self.cancelButton = [self _buttonWithTitle:title];
        
        [self.cancelButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.cancelButton];
    }
    else
    {
        [self.cancelButton removeFromSuperview];
        
        self.cancelButton = nil;
    }
    
    return KCancelButtonIndex;
}

- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.layer.borderColor = [UIColor colorWithWhite:212/255.0 alpha:1.0].CGColor;
        _textField.layer.borderWidth = 1.0f;
        _textField.layer.cornerRadius = 5.0f;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.secureTextEntry = self.alertStyleType == YTAlertViewStyleTypeSecureInput;
        _textField.delegate = (id<UITextFieldDelegate>)self;
        _textField.frame = CGRectZero;
        [self.contentView addSubview:_textField];
        [_textField becomeFirstResponder];
    }
    
    return _textField;
}

- (UIButton *)buttongForIndex:(NSInteger)index
{
    if (index == 0)
    {
        return self.cancelButton;
    }
    
    if (index > self.otherButtons.count)
    {
        return nil;
    }
    
    return [self.otherButtons objectAtIndex:index-1];
}

- (void)show:(YTAlertBlock)yxAlertBlock
{
    self.yxAlertBlock = yxAlertBlock;
    self.markView = [[UIImageView alloc] initWithFrame:[YTAlertView alertWindow].bounds];
    self.markView.image = [UIImage imageWithRadialGradient:[NSArray arrayWithObjects:[UIColor colorWithWhite:0 alpha:0.1],[UIColor colorWithWhite:0 alpha:0.2], nil ] size:[YTAlertView alertWindow].frame.size];
    
    if ([YTAlertView YTAlertViewArray].count > 0)
    {
        [[YTAlertView YTAlertViewArray] addObject:self];
    }
    else
    {
        [self _popupAlert];
        
        [[YTAlertView YTAlertViewArray] addObject:self];
    }
}

- (void)dismiss
{
    [self _buttonPressed:self.cancelButton];
}

#pragma - mark - property
- (void)setButtonTitleAttributeDictionary:(NSDictionary *)buttonTitleAttributeDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_buttonTitleAttributeDictionary ? _buttonTitleAttributeDictionary : [[self.class appearance] buttonTitleAttributeDictionary]];
    [dict addEntriesFromDictionary:buttonTitleAttributeDictionary];
    
    _buttonTitleAttributeDictionary = dict;
}

- (void)setCancelButtonTitleAttributeDictionary:(NSDictionary *)cancelButtonTitleAttributeDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_cancelButtonTitleAttributeDictionary ? _cancelButtonTitleAttributeDictionary : [[self.class appearance] cancelButtonTitleAttributeDictionary]];
    [dict addEntriesFromDictionary:cancelButtonTitleAttributeDictionary];
    
    _cancelButtonTitleAttributeDictionary = dict;
}

- (void)setButtonTitleDisableAttributeDictionary:(NSDictionary *)buttonTitleDisableAttributeDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_buttonTitleDisableAttributeDictionary ? _buttonTitleDisableAttributeDictionary : [[self.class appearance] buttonTitleDisableAttributeDictionary]];
    [dict addEntriesFromDictionary:buttonTitleDisableAttributeDictionary];
    
    _buttonTitleDisableAttributeDictionary = dict;
}

- (void)setButtonTitleHighAttributeDictionary:(NSDictionary *)buttonTitleHighAttributeDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_buttonTitleHighAttributeDictionary ? _buttonTitleHighAttributeDictionary : [[self.class appearance] buttonTitleHighAttributeDictionary]];
    [dict addEntriesFromDictionary:buttonTitleHighAttributeDictionary];
    
    _buttonTitleHighAttributeDictionary = dict;
}

#pragma - mark - private method

- (void)_buttonPressed:(UIButton *)button
{
    void(^completionBlock)(BOOL finish) = ^(BOOL finish)
    {
        if (self.yxAlertBlock)
        {
            if (button == self.cancelButton)
            {
                self.yxAlertBlock(YES, KCancelButtonIndex, self);
            }
            else
            {
                self.yxAlertBlock(NO, [self.otherButtons indexOfObject:button]+1, self);
            }
        }
        
        [[YTAlertView YTAlertViewArray] removeObject:self];
        [self.markView removeFromSuperview];
        self.markView = nil;
        [self removeFromSuperview];
        
        //        [self.mainWindow makeKeyWindow];
        
        [YTAlertView alertWindow].hidden = YES;
        
        if ([YTAlertView YTAlertViewArray].count > 0)
        {
            YTAlertView *alert = [[YTAlertView YTAlertViewArray] firstObject];
            [alert _popupAlert];
        }
    };
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
    } completion:completionBlock];
}

- (UIButton *)_buttonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button titleLabel].shadowOffset = CGSizeZero;
    [button addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma - mark - animation
- (void)_popupAlert
{
    [[YTAlertView alertWindow] addSubview:self.markView];
    [[YTAlertView alertWindow] addSubview:self];
    
    [[YTAlertView alertWindow] setHidden:NO];
    
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    self.center = CGPointMake(self.superview.frame.size.width*0.5f, self.superview.frame.size.height*0.5f);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
    bounceAnimation.duration = 0.4;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.01],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0],
                              nil];
    [self.layer addAnimation:bounceAnimation forKey:@"transform.scale"];
}

#pragma - mark - private attribute
- (void)_setButtonTitleAttribute:(UIButton *)button attribute:(NSDictionary *)attribute state:(UIControlState)state
{
    [button.titleLabel setFont:[attribute objectForKey:NSFontAttributeName]];
    [button setTitleColor:[attribute objectForKey:NSForegroundColorAttributeName] forState:state];
}

- (void)_setLabelAttribute:(UILabel *)label attribute:(NSDictionary *)attributeDictionary
{
    [label setFont:[attributeDictionary objectForKey:NSFontAttributeName]];
    [label setTextColor:[attributeDictionary objectForKey:NSForegroundColorAttributeName]];
}

- (void)_setButtonBackgroundImageAttribute:(NSDictionary *)attribute
{
    for (UIButton *button in self.otherButtons)
    {
        [button setBackgroundImage:[attribute objectForKey:[NSNumber numberWithInt:UIControlStateNormal]] forState:UIControlStateNormal];
        [button setBackgroundImage:[attribute objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
    }
}

- (void)_setCancelBackgroundImageAttribute:(NSDictionary *)attribute
{
    [self.cancelButton setBackgroundImage:[attribute objectForKey:[NSNumber numberWithInt:UIControlStateNormal]] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[attribute objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
}

#pragma - mark - private LayoutSubviews
- (CGRect)_layoutLabel:(UILabel *)label labelText:(NSString *)text rect:(CGRect)rect attribute:(NSDictionary *)attribute
{
    CGRect contentRect = rect;
    
    if (text)
    {
        [self _setLabelAttribute:label attribute:attribute];
        
        CGSize titleSize = [label.text boundingRectWithSize:contentRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size;
        
        label.frame = CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.width, titleSize.height);
        
        contentRect.origin.y += titleSize.height;
    }
    
    return contentRect;
}

- (CGRect)_layoutTextField:(CGRect)rect
{
    self.textField.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, KTextFieldHeight);
    
    rect.origin.y = CGRectGetMaxY(self.textField.frame);
    
    return rect;
}

- (CGRect)_layoutButton:(CGRect)rect
{
    CGRect contentRect = rect;
    
    NSArray *allButtons = [self _allButtons];
    
    [self _setButtonTitleAttribute:self.cancelButton attribute:self.cancelButtonTitleAttributeDictionary state:UIControlStateNormal];
    [self _setButtonTitleAttribute:self.cancelButton attribute:self.cancelButtonTitleAttributeDictionary state:UIControlStateHighlighted];
    [self _setCancelBackgroundImageAttribute:self.cancelButtonBackgroundImageAttributeDictionary];
    
    for (UIButton *button in self.otherButtons)
    {
        [self _setButtonTitleAttribute:button attribute:self.buttonTitleAttributeDictionary state:UIControlStateNormal];
        [self _setButtonTitleAttribute:button attribute:self.buttonTitleHighAttributeDictionary state:UIControlStateHighlighted];
        [self _setButtonTitleAttribute:button attribute:self.buttonTitleDisableAttributeDictionary state:UIControlStateDisabled];
    }
    [self _setButtonBackgroundImageAttribute:self.buttonBackgroundImageAttributeDictionary];
    
    if (allButtons.count < 3)
    {
        CGFloat buttonWidth = self.bounds.size.width / allButtons.count;
        CGFloat buttonOffX = self.bounds.origin.x;
        
        NSInteger index = 0;
        for (NSInteger i = allButtons.count-1; i>=0; i--)
        {
            UIButton *button = [allButtons objectAtIndex:i];
            if (0 != i)
            {
                UIFont *font = [self.cancelButtonTitleAttributeDictionary objectForKey:NSFontAttributeName];
                button.titleLabel.font = [UIFont systemFontOfSize:font.pointSize];
            }
            else
            {
                UIFont *font = [self.buttonTitleAttributeDictionary objectForKey:NSFontAttributeName];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:font.pointSize];
            }
            
            CGRect frame = CGRectMake(buttonOffX, contentRect.origin.y, buttonWidth, KAlertButtonDefaultHeight);
            
            button.frame = frame;
            
            [self _addDivideLine:frame isHorizontal:YES];
            
            if (index == 1)
            {
                [self _addDivideLine:frame isHorizontal:NO];
            }
            
            buttonOffX += buttonWidth;
            
            index ++;
        }
        
        contentRect.origin.y = CGRectGetMaxY([[allButtons lastObject] frame]);
    }
    else
    {
        for (UIButton *button in allButtons)
        {
            CGRect frame = CGRectMake(self.bounds.origin.x, contentRect.origin.y, self.bounds.size.width, KAlertButtonDefaultHeight);
            
            button.frame = frame;
            
            [self _addDivideLine:frame isHorizontal:YES];
            
            contentRect.origin.y = CGRectGetMaxY(frame);
        }
    }
    
    return contentRect;
}

- (NSArray*)_allButtons
{
    NSMutableArray *allButtons = [NSMutableArray array];
    
    if (self.otherButtons.count > 0)
    {
        [allButtons addObjectsFromArray:self.otherButtons];
    }
    
    if (self.cancelButton)
    {
        [allButtons addObject:self.cancelButton];
    }
    
    return allButtons;
}

- (UILabel *)_addTitleLabel:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

- (void)_addDivideLine:(CGRect)rect isHorizontal:(BOOL)yesOrNo
{
    UIView *view = [[UIView alloc] init];
    
    if (yesOrNo)
    {
        view.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0.5);
    }
    else
    {
        view.frame = CGRectMake(rect.origin.x, rect.origin.y, 0.5, rect.size.height);
    }
    
    view.backgroundColor = self.divideLineColor;
    
    [self.lineArray addObject:view];
    
    [self addSubview:view];
}

#pragma - mark - NSNotification
- (void)_keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.center = CGPointMake(self.superview.frame.size.width*0.5f, ([UIScreen mainScreen].bounds.size.height-keyboardFrame.size.height)/2+[UIApplication sharedApplication].statusBarFrame.size.height);
    
    [self setNeedsLayout];
}

- (void)_keyboardWillHide:(NSNotification *)notification
{
    self.center = CGPointMake(self.superview.frame.size.width*0.5f, self.superview.frame.size.height*0.5f);
    
    [self setNeedsLayout];
}

#pragma - mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _buttonPressed:[self.otherButtons lastObject]];
    
    return YES;
}


@end

