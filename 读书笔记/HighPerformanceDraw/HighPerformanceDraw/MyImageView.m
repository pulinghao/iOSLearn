//
//  MyImageView.m
//  HighPerformanceDraw
//
//  Created by pulinghao on 2022/10/2.
//

#import "MyImageView.h"

@implementation MyImageView

- (void)show{
    [self setNeedsDisplayInRect:CGRectMake(0, 0, 100, 200)];
}

- (void)drawRect:(CGRect)rect{
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size];
    UIImage *image = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
