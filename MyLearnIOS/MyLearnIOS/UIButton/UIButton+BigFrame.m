//
//  UIButton+BigFrame.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/18.
//

#import "UIButton+BigFrame.h"
#import <objc/runtime.h>

@interface UIButton (BigFrame)

@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

@end

static const NSString *KEY_HIT_TEST = @"hitTestEdgeInsets";
@implementation UIButton (BigFrame)

@dynamic hitTestEdgeInsets;

- (void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self,&KEY_HIT_TEST, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST);
    if (value){
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end
