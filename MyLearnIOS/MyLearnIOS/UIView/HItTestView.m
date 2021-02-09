//
//  HItTestView.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/2/7.
//

#import "HItTestView.h"

@implementation HItTestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"poininside");
    BOOL poinInside =  [super pointInside:point withEvent:event];
//    NSLog(@"view1:%p",self);
    return poinInside;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"hittest");
    NSLog(@"view1:%p",self);
    UIView *returnView = [super hitTest:point withEvent:event];
    NSLog(@"view1 returnview:%p",returnView);
    return returnView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch begin");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch end");
}
@end
