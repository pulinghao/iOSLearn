//
//  PrivateSarkWife.m
//  巧用 Class Extension 分离接口依赖
//
//  Created by pulinghao on 2022/8/21.
//

#import "PrivateSarkWife.h"
#import "Sark+Internal.h" // <--- 私有依赖
@implementation PrivateSarkWife

- (void)robAllMoneyFromCreditCardOfSark:(Sark *)sark {
    NSString *password = sark.creditCardPassword; // oh yeah!
}

@end
