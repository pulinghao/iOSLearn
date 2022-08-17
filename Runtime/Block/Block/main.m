//
//  main.m
//  Block
//
//  Created by pulinghao on 2022/8/17.
//

#import <Foundation/Foundation.h>
#import "Block.h"
#import "MyObject.h"

int val = 10;
void (^blk)(void) = ^{
    printf("global block %d,\n",val);
};


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        blk(); //全局block
//
//        void (^blk2)(void) = ^{
//            printf("global block %d,\n",val);
//        };
//        blk2(); //全局block
        
        Block *b = [[Block alloc] init];
        id obj = [b getBlockArraySafeInMRC];
        typedef void  (^blk_t)(void);
        blk_t blk3 = (blk_t)[obj objectAtIndex:0];
        blk3();
        
        
        __block int val4 = 12;
        void (^blk4)(void) = [^{val4 = 14;} copy];
        val4 = 13;
        blk4();
        printf("%d\n",val4);
        
        int val5 = 10;
        void (^blk_on_stack)(void) = ^{
            printf("stack block %d,\n",val5);
        };
        
//        void (^blk_on_heap)(void) = [blk_on_stack copy];
        void (^blk_on_heap)(void) = Block_copy(blk_on_stack);
        
        id o = [[MyObject alloc] init];
        NSLog(@"%@",o);
        
    }
    return 0;
}
