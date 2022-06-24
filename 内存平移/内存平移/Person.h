//
//  Person.h
//  内存平移
//
//  Created by pulinghao on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

- (void)saySomething;

@end

NS_ASSUME_NONNULL_END
