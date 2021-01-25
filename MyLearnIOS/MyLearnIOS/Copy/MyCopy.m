//
//  MyCopy.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/21.
//

#import "MyCopy.h"

@interface MyCopy()

@property (nonatomic, strong) NSString *strongStr;
@property (nonatomic, copy) NSString *copyedStr;

@end
@implementation MyCopy

- (instancetype)init
{
    self = [super init];
    if (self) {
//        NSString *string = [NSString stringWithFormat:@"abc"];
//        self.strongStr = string;
//        self.copyedStr = [string copy];
//        NSLog(@"originString1: %p, %p,%@", string,&string,string);
//        NSLog(@"strongString1: %p, %p,%@", _strongStr,&_strongStr,self.strongStr);
//        NSLog(@"copyString1:   %p, %p,%@", _copyedStr,&_copyedStr,self.copyedStr);
//
//        //改变string的值
//        string = @"123";
//
//        NSLog(@"originString11: %p, %p,%@", string, &string,string);
//        NSLog(@"strongString11: %p, %p,%@", _strongStr,&_strongStr,self.strongStr);
//        NSLog(@"copyString11:   %p, %p,%@", _copyedStr,&_copyedStr,self.copyedStr);
//
        [self test];
    }
    return self;
}


- (void)testTwo {
    NSMutableString *string= [[NSMutableString alloc] initWithString:@"abc"];
    self.strongStr = string;
    self.copyedStr = string;
    NSLog(@"originString2: %p,%p,%@", string, &string,string);
    NSLog(@"strongString2: %p,%p,%@", _strongStr,&_strongStr,self.strongStr);
    NSLog(@"copyString2:   %p,%p,%@", _copyedStr,&_copyedStr,self.copyedStr);

//改变string的值
    [string appendFormat:@"%@",@"123"];

    NSLog(@"originString2: %p,%p,%@", string, &string,string);
    NSLog(@"strongString2: %p,%p,%@", _strongStr,&_strongStr,self.strongStr);
    NSLog(@"copyString2:   %p,%p,%@", _copyedStr,&_copyedStr,self.copyedStr);
}

- (void)test {
    NSMutableString *string= [[NSMutableString alloc] initWithString:@"abc"];
    self.strongStr = string;
    self.copyedStr = string;
    NSLog(@"strongString: %@", self.strongStr);
    NSLog(@"copyString:   %@", self.copyedStr);

//改变string的值
    [string appendFormat:@"%@",@"123"];
    
    NSLog(@"strongString: %@", self.strongStr);
    NSLog(@"copyString:   %@", self.copyedStr);
}
@end
