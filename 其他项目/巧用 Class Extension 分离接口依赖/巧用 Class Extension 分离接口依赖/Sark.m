//
//  Sark.m
//  巧用 Class Extension 分离接口依赖
//
//  Created by pulinghao on 2022/8/21.
//

#import "Sark.h"
#import "Sark+Internal.h"
#import "Sark+Other.h"


@interface Sark()

@property (nonatomic, copy) NSString *sarkName;

@end

@implementation Sark

- (void)setYourSarkName:(NSString *)name{
    self.sarkName = name;
}
@end
