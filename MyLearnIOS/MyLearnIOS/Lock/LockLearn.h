//
//  LockLearn.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LockLearn : NSObject

- (void)testOSSpinLock;

- (void)testOSSpinLock2;

- (void)testOSUnfairLock;

- (void)testPThread;

- (void)testConditionLock;

- (void)testConditionLock2;


- (void)POSIX_Codictions;
@end

NS_ASSUME_NONNULL_END
