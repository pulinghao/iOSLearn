//
//  RuntimeLearn.h
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RuntimeLearn : NSObject

- (void)exchangeMethod;

// 消息转发
- (void)resolve;

- (void)forwardingTarget;

- (void)invocation;

@end

NS_ASSUME_NONNULL_END
