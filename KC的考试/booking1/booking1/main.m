//
//  main.m
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import <Foundation/Foundation.h>

#import "NSArray+DeltaCoder.h"
#import "Person.h"
#import "Solution.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSArray *array = @[@1000,@0,@100];
        NSArray *delta = [array deltaEncoded];
        NSLog(@"Hello, World!");
        
        NSMutableString *muta = [[NSMutableString alloc] init];
        Person *person = [[Person alloc] init];
        person.firstName = nil;
        person.middleName = nil;
        person.lastName = @"McBain";
        NSArray *temp =@[
            @"36 30 36 30",
            @"30 36 30 30",
            @"15 15 15 15",
            @"46 96 90 90 100",
            @"100 200 100 200",
            @"-100 -100 -100",
            @"100",
        ];
//        Solution
        PolygonCount *count = [Solution polygonCountsFromLines:temp];
        NSLog(@"fullName = %@", person.fullName);
   
    }
    return 0;
}
