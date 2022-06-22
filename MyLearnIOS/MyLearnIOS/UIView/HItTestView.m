//
//  HItTestView.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/2/7.
//

#import "HItTestView.h"

@interface HItTestView()

@property (nonatomic, strong) UIView *myView;

@end

@implementation HItTestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, 200, 100);
        CGRect rect2 = CGRectMake(0, 0, 150, 50);
        CGRect rectRest = CGRectIntersection(rect, rect2);           //返回交集
        BOOL rectInterSectRect2 = CGRectIntersectsRect(rect, rect2); //是否有交集
        CGRectContainsPoint(rect, CGPointMake(0, 0));                //点是否在矩形区域内
        
//        UIFont *font = [UIFont preferredFontForTextStyle:<#(nonnull UIFontTextStyle)#>]
        
        UIImageView *image = [[UIImageView alloc] init];
//        image.contentMode = UIViewContentModeRedraw;
        
        _myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
        _myView.backgroundColor = [UIColor redColor];
        [self addSubview:_myView];
    }
    return self;
}


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
