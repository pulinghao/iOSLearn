//
//  main.m
//  autorelease2
//
//  Created by pulinghao on 2022/8/22.
//

#import <Foundation/Foundation.h>

extern void _objc_autoreleasePoolPrint(void);

@interface MyObject : NSObject


@end


@implementation MyObject

- (id)object{
    id obj = [[MyObject alloc] init];
//    [obj autorelease];
    return obj;
}

+ (id)create{
    id obj = [[MyObject alloc] init];
    return obj;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        MyObject *obj = [MyObject create];
        _objc_autoreleasePoolPrint();
    }
    return 0;
}
