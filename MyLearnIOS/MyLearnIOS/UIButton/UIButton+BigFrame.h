//
//  UIButton+BigFrame.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/18.
//  扩大按钮的点击区域

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (BigFrame)

- (void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets;
@end

NS_ASSUME_NONNULL_END
