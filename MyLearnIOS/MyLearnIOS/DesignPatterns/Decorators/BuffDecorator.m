//
//  BuffDecorator.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/3/6.
//

#import "BuffDecorator.h"

@interface BuffDecorator()
@property (nonatomic, strong) Hero *hero;
@end

@implementation BuffDecorator

- (instancetype)initWithHero:(Hero *)hero {
    self = [super init];
    if (self) {
        _hero = hero;
    }
    return self;
}

- (void)blessBuff {
    [_hero blessBuff];
    NSLog(@"额外buff:");
}

@end


@implementation RedBuffDecorator

- (void)blessBuff {
    [super blessBuff];
    NSLog(@"红buff: 攻击附加真实伤害，并造成灼烧效果");
}
@end

@implementation BlueBuffDecorator
- (void)blessBuff {
    [super blessBuff];
    NSLog(@"蓝buff: 蓝量回复速度加快，并且缩减技能CD");
}
@end
