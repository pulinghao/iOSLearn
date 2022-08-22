//
//  main.m
//  autorelease
//
//  Created by pulinghao on 2022/8/22.
//

#import <Foundation/Foundation.h>

extern void _objc_autoreleasePoolPrint(void);
extern uintptr_t _objc_rootRetainCount(id obj);

@interface MyObject : NSObject


@end


@implementation MyObject

- (id)object{
    id obj = [[MyObject alloc] init];
//    [obj autorelease];
    return obj;
}

+ (id)create{
    return [[MyObject alloc] init];
}

@end

void test1(){
    id __weak obj1 = nil;
    {
        id  obj0 = [NSMutableArray array];
//        [obj0 addObject:@"obj"];
//        obj1 = obj0;
        NSLog(@"obj0 = %@", obj0);
        _objc_autoreleasePoolPrint();
    }
   
    NSLog(@"obj1 = %@", obj1);
}


//void test2(){
//    //例二：
//    id __unsafe_unretained obj1 = nil;
//    {
//        id  obj0 = [[NSMutableArray alloc] init];
//        [obj0 addObject:@"obj"];
//        obj1 = obj0;
//        NSLog(@"obj0 = %@", obj0);
//    }
//
//    NSLog(@"obj1 = %@", obj1);
//    _objc_autoreleasePoolPrint();
//}
//
//void test3(){
//    id array = [NSMutableArray arrayWithCapacity:1];
//    id __unsafe_unretained array_1 = [NSMutableArray array];
//    id array_2 = [NSMutableArray array];
//    id __weak weakArray = [NSMutableArray arrayWithCapacity:1];
//    id __unsafe_unretained unsaferetainedArray = [NSMutableArray arrayWithCapacity:1];
//    NSLog(@"array: %p", array);
//    NSLog(@"array_1: %p", array_1);
//    NSLog(@"array_2: %p", array_2);
//    NSLog(@"weakArray: %p", weakArray);
//    NSLog(@"unsaferetainedArray: %p", unsaferetainedArray);
//    _objc_autoreleasePoolPrint();
//}

void test4(){
    id __unsafe_unretained obj1 = nil;
        
    @autoreleasepool {
        id obj0 = [NSMutableArray arrayWithObjects:@"obj",nil];
        obj1 = obj0;
        NSLog(@"obj0 = %@", obj0);
    }
    
    NSLog(@"obj1 = %@", obj1);
}

void test5(){
    @autoreleasepool {
           
       for (int i = 0; i < 5; i++) {
//           NSObject *objc = [[NSObject alloc] autorelease];
       }
       _objc_autoreleasePoolPrint();
       
   }
}

void test6(){
    @autoreleasepool {
        MyObject *obj = [MyObject create];
        NSLog(@"%@",obj);
        _objc_autoreleasePoolPrint();
    }
}

void test7(){
    id __weak obj0;
    {
        id obj2 = [NSMutableArray array];
        obj0 = obj2;
        NSLog(@"%p", obj2);
        NSLog(@"%lu", _objc_rootRetainCount(obj2));
        _objc_autoreleasePoolPrint();   //输出1个autorelease对象
    }
    NSLog(@"obj0-2-%@", obj0);
}

void test8(){
    ///////////////////////////////////////////////////////////////////////////////////////////// 1.
        id obj0;
        {
            id obj1 = [NSMutableArray array];
            obj0 = obj1;
            _objc_autoreleasePoolPrint();
        }
        NSLog(@"obj0-%@", obj0);
        
    ///////////////////////////////////////////////////////////////////////////////////////////// 2.
        id __weak obj2;
        {
            id obj3 = [NSMutableArray array];
            obj2 = obj3;
            _objc_autoreleasePoolPrint();
        }
        NSLog(@"obj2-%@", obj2);
        
    ///////////////////////////////////////////////////////////////////////////////////////////// 3.
        id __weak obj4;
        @autoreleasepool {
            id obj5 = [NSMutableArray array];
            obj4 = obj5;
            _objc_autoreleasePoolPrint();
        }
        NSLog(@"obj4-%@", obj4);
}
int main(int argc, const char * argv[]) {
    //例一
//    test1();
//    test2();
//    test3();
//    test4();
    
//    test5();
//    test6();
//    test7();
    test8();
    
    return 0;
}
