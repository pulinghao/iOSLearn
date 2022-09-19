//
//  Person.h
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *middleName;

@property (nonatomic, copy) NSString *lastName;

- (NSString *)fullName;

@end

NS_ASSUME_NONNULL_END
