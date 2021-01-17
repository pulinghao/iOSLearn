//
//  KVOPerson.h
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOPerson : NSObject

@property (nonatomic, assign) int steps;

// 依赖关系的成员
@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;

@end

NS_ASSUME_NONNULL_END
