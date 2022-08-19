//
//  main.m
//  KC的考试4
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSObject *a = [NSObject alloc];
        void (^__weak block1)(void) = nil; //使用weak崩溃， 去掉weak正常
        {
            void(^block2)(void) = ^{
                NSLog(@"----%@",a);
            };
            block1 = block2;
            NSLog(@"1 - %@, %@",block1,block2);
        }
        block1();
    }
    return 0;
}
