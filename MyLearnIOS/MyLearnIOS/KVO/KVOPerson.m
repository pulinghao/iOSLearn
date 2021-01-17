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



@end
