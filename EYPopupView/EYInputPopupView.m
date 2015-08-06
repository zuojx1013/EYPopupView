//
//  EYInputPopupView.m
//  EYPopupView_Example
//
//  Created by ericyang on 8/5/15.
//  Copyright (c) 2015 Eric Yang. All rights reserved.
//

#import "EYInputPopupView.h"
#define _K_SCREEN_WIDTH ([[UIScreen mainScreen ] bounds ].size.width)

#define kAlertWidth (245  * _K_SCREEN_WIDTH/320)

#define kContentMaxHeight 300.0f
#define kContentMinHeight 34.0f
#define kContentWidth kAlertWidth - 16

#define kTitleYOffset 15.0f
#define kTitleHeight 25.0f

#define kSingleButtonWidth (160.0f * _K_SCREEN_WIDTH/320)
#define kCoupleButtonWidth (107.0f * _K_SCREEN_WIDTH/320)
#define kButtonHeight 40.0f
#define kButtonBottomOffset 10.0f
@interface EYInputPopupView ()<UITextViewDelegate>
{
    BOOL _leftLeave;
}

@property (nonatomic, strong) UILabel *alertTitleLabel;
@property (nonatomic, strong) UITextView *alertContentLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIView *backImageView;


@end


@implementation EYInputPopupView{
    float alertHeight;//default 160
    float contentHeight;// kContentMinHeight <= contentHeight <=kContentMaxHeight , default kContentMinHeight
}
    


- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
{
    if (self = [super init]) {
        
        alertHeight=160.0f;
        contentHeight=kContentMinHeight;
        
        
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        self.alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTitleYOffset, kAlertWidth, kTitleHeight)];
        self.alertTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.alertTitleLabel.textColor = [UIColor colorWithRed:56.0/255.0 green:64.0/255.0 blue:71.0/255.0 alpha:1];
        [self addSubview:self.alertTitleLabel];
        self.alertTitleLabel.text = title;
        
        self.alertContentLabel = [[UITextView alloc] initWithFrame:CGRectMake((kAlertWidth - kContentWidth) * 0.5, CGRectGetMaxY(self.alertTitleLabel.frame), kContentWidth, contentHeight)];
        self.alertContentLabel.editable=YES;
        self.alertContentLabel.selectable=YES;
        self.alertContentLabel.textAlignment = self.alertTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.alertContentLabel.textColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1];
        self.alertContentLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:self.alertContentLabel];
        self.alertContentLabel.text = content;
        
        CGFloat fixedWidth = self.alertContentLabel.frame.size.width;
        CGSize newSize = [self.alertContentLabel sizeThatFits:CGSizeMake(fixedWidth, kContentMaxHeight)];
        newSize.height=fmin(kContentMaxHeight, newSize.height);//not larger than kContentMaxHeight
        newSize.height=fmax(kContentMinHeight, newSize.height);//not less than kContentMinHeight
        CGRect newFrame = self.alertContentLabel.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        self.alertContentLabel.frame = newFrame;
        self.alertContentLabel.scrollEnabled=self.alertContentLabel.frame.size.height==kContentMaxHeight;

        alertHeight+=(newSize.height-kContentMinHeight);// alertHeight + diffHeight
        {
            CGRect leftBtnFrame = CGRectMake((kAlertWidth - 2 * kCoupleButtonWidth - kButtonBottomOffset) * 0.5, alertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
            CGRect rightBtnFrame = CGRectMake(CGRectGetMaxX(leftBtnFrame) + kButtonBottomOffset, alertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
            self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.leftBtn.frame = leftBtnFrame;
            self.rightBtn.frame = rightBtnFrame;
        }
        
        [self.rightBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:87.0/255.0 green:135.0/255.0 blue:173.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.leftBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:227.0/255.0 green:100.0/255.0 blue:83.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.rightBtn setTitle:@"确认" forState:UIControlStateNormal];
        [self.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.leftBtn.titleLabel.font = self.rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.leftBtn.layer.masksToBounds = self.rightBtn.layer.masksToBounds = YES;
        self.leftBtn.layer.cornerRadius = self.rightBtn.layer.cornerRadius = 3.0;
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
        
        
        
        
        UIButton *xButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [xButton setImage:[UIImage imageNamed:@"EYPopupView.bundle/btn_close_normal.png"] forState:UIControlStateNormal];
        [xButton setImage:[UIImage imageNamed:@"EYPopupView.bundle/btn_close_selected.png"] forState:UIControlStateHighlighted];
        xButton.frame = CGRectMake(kAlertWidth - 32, 0, 32, 32);
        [self addSubview:xButton];
        [xButton addTarget:self action:@selector(dismissAlert) forControlEvents:UIControlEventTouchUpInside];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

- (void)leftBtnClicked:(id)sender
{
    _leftLeave = YES;
    [self dismissAlert];
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)rightBtnClicked:(id)sender
{
    _leftLeave = NO;
    [self dismissAlert];
    if (self.rightBlock) {
        self.rightBlock();
    }
}

- (void)show
{
    UIViewController *topVC = [self appRootViewController];
    self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, - alertHeight - 30, kAlertWidth, alertHeight);
    [topVC.view addSubview:self];
}

- (void)dismissAlert
{
    [self removeFromSuperview];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


- (void)removeFromSuperview
{
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    UIViewController *topVC = [self appRootViewController];
    CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), kAlertWidth, alertHeight);
    
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
        if (_leftLeave) {
            self.transform = CGAffineTransformMakeRotation(-M_1_PI / 1.5);
        }else {
            self.transform = CGAffineTransformMakeRotation(M_1_PI / 1.5);
        }
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIViewController *topVC = [self appRootViewController];
    
    if (!self.backImageView) {
        self.backImageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.6f;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPress:)];
        tapGesture.numberOfTapsRequired=1;
        [self.backImageView addGestureRecognizer:tapGesture];
        
    }
    [topVC.view addSubview:self.backImageView];
    self.transform = CGAffineTransformMakeRotation(-M_1_PI / 2);
    CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - alertHeight) * 0.5, kAlertWidth, alertHeight);
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = afterFrame;
    } completion:^(BOOL finished) {
    }];
    [super willMoveToSuperview:newSuperview];
}

#pragma mark UITapGestureRecognizer
-(void)handleTapPress:(UITapGestureRecognizer *)gestureRecognizer
{
    _leftLeave = YES;
    [self dismissAlert];
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
        return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    
}

#pragma mark -
-(void)resetBottomLayout{
    CGSize labelSize = [self.alertContentLabel sizeThatFits:CGSizeMake(kContentWidth, 1000)];
    {
        CGRect frame=self.alertContentLabel.frame;
        frame.size.height=MAX(labelSize.height, kContentMinHeight);
        frame.size.height=MIN(labelSize.height, kContentMaxHeight);
        self.alertContentLabel.frame=frame;
        self.alertContentLabel.scrollEnabled=self.alertContentLabel.frame.size.height==kContentMaxHeight;
    }
    {
        CGRect leftBtnFrame = CGRectMake((kAlertWidth - 2 * kCoupleButtonWidth - kButtonBottomOffset) * 0.5, alertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
        CGRect rightBtnFrame = CGRectMake(CGRectGetMaxX(leftBtnFrame) + kButtonBottomOffset, alertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftBtn.frame = leftBtnFrame;
        self.rightBtn.frame = rightBtnFrame;
    }
    
}
@end

