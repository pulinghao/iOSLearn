//
//  RuntimeAPI.h
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RuntimeAPI : NSObject <NSCoding>

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* address;

- (instancetype)initWithCoder:(NSCoder *)coder;
@end

NS_ASSUME_NONNULL_END
