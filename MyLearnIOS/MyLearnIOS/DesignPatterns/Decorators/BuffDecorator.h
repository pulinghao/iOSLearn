//
//  BuffDecorator.h
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/3/6.
//

#import "Hero.h"

NS_ASSUME_NONNULL_BEGIN

@interface BuffDecorator : Hero

- (instancetype)initWithHero:(Hero *)hero;


@end


@interface RedBuffDecorator : BuffDecorator

@end



@interface BlueBuffDecorator : BuffDecorator

@end
NS_ASSUME_NONNULL_END
