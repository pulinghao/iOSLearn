//
//  PLHUIViewController.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/6/19.
//

#import "PLHUIViewController.h"
#import "HItTestView.h"


@interface PLHUIViewController ()
@property (nonatomic, strong) HItTestView *hitTestView;
@property (nonatomic, strong) CALayer *colorLayer;
@property (nonatomic, strong) UIView *layerView;

@end
@implementation PLHUIViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
//    self.layerView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 300, 300)];
//    [self.view addSubview:self.layerView];
//    self.layerView.layer.backgroundColor = [UIColor blueColor].CGColor;
//    
//    self.colorLayer = [CALayer layer];
//    self.colorLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
//    self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;
//        //add it to our view
//    [self.layerView.layer addSublayer:self.colorLayer];
    
    
    //呈现层与展示层
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(0, 0, 100, 100);
    self.colorLayer.position = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    self.colorLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:self.colorLayer];
    
    self.hitTestView = [[HItTestView alloc] initWithFrame:CGRectMake(50, 300, 100, 50)];
    self.hitTestView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.hitTestView];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"PLHUIViewController touches");
    
    //隐式动画
//    [self hideAnimation];
    
    //改变动画时间
//    [self changeTime];
    
    //呈现层与展示层
    [self presentationLayerAndModelLayer:touches];
//    //begin a new transaction
//    [CATransaction begin];
//    //set the animation duration to 1 second
//    [CATransaction setAnimationDuration:1.0];
//    //randomize the layer background color
//    CGFloat red = arc4random() / (CGFloat)INT_MAX;
//    CGFloat green = arc4random() / (CGFloat)INT_MAX;
//    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
//    self.layerView.layer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
//    //commit the transaction
//    [CATransaction commit];
}

// 隐式动画
- (void)hideAnimation{
    //randomize the layer background color
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
}

- (void)changeTime{
    [CATransaction begin];
    //set the animation duration to 3 second
    [CATransaction setAnimationDuration:3.0];
    //randomize the layer background color
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
    [CATransaction commit];
}

- (void)presentationLayerAndModelLayer:(NSSet<UITouch *> *)touches{
    //get the touch point
       CGPoint point = [[touches anyObject] locationInView:self.view];
       //check if we've tapped the moving layer
       if ([self.colorLayer.presentationLayer hitTest:point]) {
           //randomize the layer background color
           CGFloat red = arc4random() / (CGFloat)INT_MAX;
           CGFloat green = arc4random() / (CGFloat)INT_MAX;
           CGFloat blue = arc4random() / (CGFloat)INT_MAX;
           self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
       } else {
           //otherwise (slowly) move the layer to new position
           [CATransaction begin];
           [CATransaction setAnimationDuration:4.0];
           self.colorLayer.position = point;
           [CATransaction commit];
       }
}
@end
