//
//  main.m
//  FishHookTest
//
//  Created by pulinghao on 2021/9/2.
//

#import <Foundation/Foundation.h>
#include "fishhook.h"

// 原始函数
static int (*orignal_strlen)(const char* _s);

// 新函数
int new_strlen(const char *_s){
    return 123;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        char *str = "hello world";
        int length = strlen(str);
        printf("%ld\n",length);
        struct rebinding strlen_rebinding = {"strlen",new_strlen,(void *)&orignal_strlen};
        
        rebind_symbols((struct rebinding[1]){strlen_rebinding}, 1);
        
        length = strlen(str);
        printf("%ld\n",length);
    }
    return 0;
}
