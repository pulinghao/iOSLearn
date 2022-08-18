//
//  KVOPerson.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import "KVOPerson.h"

@implementation KVOPerson


- (NSString*)fullName {
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

// 设置依赖关系
+ (NSSet*) keyPathsForValuesAffectingFullName
{
    return [NSSet setWithObjects:@"lastName", @"firstName", nil];
}

// 手动
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString: @"firstName"]) {
        return NO; //关闭
    }
    return [super automaticallyNotifiesObserversForKey:key];
}


- (void)setFirstName:(NSString *)firstName
{
    if ([_firstName isEqualToString:firstName]) {
        return;
    }
    [self willChangeValueForKey:firstName];
    _firstName = firstName;
    [self didChangeValueForKey:firstName];
}
@end
