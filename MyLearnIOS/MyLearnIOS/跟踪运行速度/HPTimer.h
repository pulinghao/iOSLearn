//
//  HPTimer.h
//  MyLearnIOS
//
//  Created by pulinghao on 2022/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPTimer : NSObject

+ (HPTimer *)startWithName:(NSString *)name;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) uint64_t timeNanos;

- (uint64_t)stop;
- (void)printTree;
@end

NS_ASSUME_NONNULL_END
