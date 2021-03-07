//
//  Hero.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/3/6.
//

#import "Hero.h"

@implementation Hero

- (void)blessBuff {
    NSAssert(false, @"must implement in subClass");
}

@end

@implementation Galen
- (void)blessBuff {
    NSLog(@"盖伦被动技能：脱离战斗后回血加快");
}
@end


@implementation Timo
- (void)blessBuff {
    NSLog(@"提莫被动技能：脱离战斗后，静止不动一段时间进入隐身");
}
@end
