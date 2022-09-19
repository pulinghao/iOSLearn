//
//  Person.m
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import "Person.h"

@implementation Person

- (NSString *)fullName{
    
    NSLog(@"%@ %@ %@", self.firstName,self.middleName, self.lastName);
    NSMutableString *fullName = [[NSMutableString alloc] init];
    if(self.firstName.length > 0){
        [fullName appendString:self.firstName];
    }
    if(self.middleName.length > 0){
        if(self.firstName.length > 0){
            [fullName appendString:@" "];
        }
        [fullName appendString:self.middleName];
    }
    
    if(self.lastName.length > 0){
        if(self.middleName.length > 0 || self.firstName.length > 0){
            [fullName appendString:@" "];
        }
        [fullName appendString:self.lastName];
    }
    return [fullName copy];
}

@end
