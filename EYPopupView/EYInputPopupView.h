//
//  EYInputPopupView.h
//  EYPopupView_Example
//
//  Created by ericyang on 8/5/15.
//  Copyright (c) 2015 Eric Yang. All rights reserved.
//

#import "EYPopupView.h"

/**
 [EYInputPopupView popViewWithTitle:@"我是标题我是标题我是标题我是标题" contentText:@"Do somethi"
 type:EYInputPopupView_Type_single_line_text
 cancelBlock:^{
 
 } confirmBlock:^(UIView *view, NSString *text) {
 
 } dismissBlock:^{
 
 }];
 */

typedef void (^clickBlock)(UIView* view, NSString* text);
@interface EYInputPopupView : EYPopupView

+ (void)popViewWithTitle:(NSString *)title
             contentText:(NSString *)content
                    type:(EYInputPopupView_Type)type
             cancelBlock:(dispatch_block_t)cancelBlock
            confirmBlock:(clickBlock)confirmBlock
            dismissBlock:(dispatch_block_t)dismissBlock;
@end
