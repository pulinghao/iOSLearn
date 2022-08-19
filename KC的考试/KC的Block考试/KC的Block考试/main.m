//
//  main.m
//  KC的Block考试
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSObject *objc = [NSObject new];
        void(^blk)(void) = ^{
            NSLog(@"%@",objc);
        };
        blk();
    }
    return 0;
}
