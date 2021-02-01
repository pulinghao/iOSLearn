//
//  CircleTransition.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/31.
//

#import "CircleTransition.h"
#import "TransitionViewController1.h"
#import "TransitionViewController2.h"

@interface CircleTransition()<CAAnimationDelegate>

@property (nonatomic, strong) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, assign) BOOL isPush;

@end
@implementation CircleTransition

#pragma mark UIViewControllerAnimatedTransitioning
// 动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

// 上下文，实现具体的动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // 1. 动画拆分 2个圆
    
    // 1. 持有上下文
    _context = transitionContext;
    
    // 2. 获取一个View的容器
    UIView *containerView = [transitionContext containerView];
    
    // 3.获取toVC的view，添加到容器中
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:toVC.view];
    
    // 4. 添加动画
    TransitionViewController1 *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIButton *btn;
    TransitionViewController1 *VC1;
    TransitionViewController2 *VC2;
    if (_isPush) {
        VC1 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        VC2 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        btn = VC1.redBtn;

    }else{
        VC2 = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        VC1 = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        btn = VC2.blackBtn;
    }
    [containerView addSubview:VC1.view];
    [containerView addSubview:VC2.view];
//    ViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIButton *btn = fromVC.blackBtn;
    //5.画一个小圆(大小圆的中心点是一样)
    UIBezierPath *smallPath = [UIBezierPath bezierPathWithOvalInRect:btn.frame];
    //6.中心点
    CGPoint centerP;
    centerP = btn.center;
    //7.求大圆的半径
    CGFloat radius;
    //8.判断按钮在哪个象限
    CGFloat y = CGRectGetHeight(toVC.view.frame)-btn.center.y;
    CGFloat x = CGRectGetWidth(toVC.view.frame) - btn.center.x;
    if (btn.frame.origin.x > CGRectGetWidth(toVC.view.frame)/2) {
        if (btn.frame.origin.y < CGRectGetHeight(toVC.view.frame)/2) {
            //1
            radius = sqrtf(btn.center.x*btn.center.x + y*y);
        }else{
            //4
            radius = sqrtf(btn.center.x*btn.center.x + btn.center.y*btn.center.y);
        }
    }else{
        if (CGRectGetMaxY(btn.frame) < CGRectGetHeight(toVC.view.frame)/2) {
            //2
            radius = sqrtf(x*x + y*y);
        }else{
            //3
            radius = sqrtf(btn.center.y*btn.center.y + x*x);
        }
    }
    //9.用贝塞尔画大圆
    UIBezierPath *bigPath = [UIBezierPath bezierPathWithArcCenter:centerP radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    //10.把path添加到layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    if (_isPush) {
        shapeLayer.path = bigPath.CGPath;
    }else{
        shapeLayer.path = smallPath.CGPath;
    }
//    [toVC.view.layer addSublayer:shapeLayer];
    //11.蒙板
    TransitionViewController1 *VC;
    if (_isPush) {
        VC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }else{
        VC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    }
    VC.view.layer.mask = shapeLayer;
    //12.动画
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"path";
    if (_isPush) {
        anim.fromValue = (id)smallPath.CGPath;

    }else{
        anim.fromValue = (id)bigPath.CGPath;

    }
//    anim.toValue = bigPath; //toValue一般是不写的，只写fromValue
    anim.delegate = self;
    [shapeLayer addAnimation:anim forKey:nil];
}

@end
