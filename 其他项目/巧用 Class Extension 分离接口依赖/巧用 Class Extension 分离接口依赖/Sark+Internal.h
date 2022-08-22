//
//  Sark+Internal.h
//  巧用 Class Extension 分离接口依赖
//
//  Created by pulinghao on 2022/8/21.
//

#import "Sark.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sark ()
@property (nonatomic, copy) NSString *creditCardPassword;
@end



@interface Sark (Internal)

@end

NS_ASSUME_NONNULL_END
