//
//  NSArray+Safe.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/8/23.
//

#import "NSArray+Safe.h"
#import <objc/runtime.h>

@implementation NSArray (Safe)

+ (BOOL)systemSelector:(SEL)systemSelector customSelector:(SEL)customSelector error:(NSError *)error{
    Method systemMothod = class_getInstanceMethod(self, systemSelector);
    if (!systemMothod) {
        return NO;
    }
    
    Method swizzleMethod = class_getInstanceMethod(self, customSelector);
    if (!swizzleMethod) {
        return NO;
    }
    
    if (class_addMethod([self class], customSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod([self class], customSelector, method_getImplementation(systemMothod), method_getTypeEncoding(systemMothod));
    } else {
        method_exchangeImplementations(systemMothod, swizzleMethod);
    }
    
    return YES;
    
}

+ (void)load{
    // 这个方法，获取 NSArray的所有子类
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    if (numClasses >0 ){
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            if (class_getSuperclass(classes[i]) == [NSArray class]){
                NSLog(@"NSArray Safe:%@", NSStringFromClass(classes[i]));
            }
        }
        free(classes);
    }
    
    
    [super load];
    // 越界：初始化的空数组
    [objc_getClass("__NSArray0") systemSelector:@selector(objectAtIndex:)
                               customSelector:@selector(emptyObjectIndex:)
                                          error:nil];
    // 越界：初始化的非空不可变数组
    [objc_getClass("__NSSingleObjectArrayI") systemSelector:@selector(objectAtIndex:)
                                           customSelector:@selector(singleObjectIndex:)
                                                      error:nil];
    // 越界：初始化的非空不可变数组
    [objc_getClass("__NSArrayI") systemSelector:@selector(objectAtIndex:)
                               customSelector:@selector(safe_arrObjectIndex:)
                                          error:nil];
    // 越界：初始化的可变数组
    [objc_getClass("__NSArrayM") systemSelector:@selector(objectAtIndex:)
                               customSelector:@selector(safeObjectIndex:)
                                          error:nil];
    // 越界：未初始化的可变数组和未初始化不可变数组
    [objc_getClass("__NSPlaceholderArray") systemSelector:@selector(objectAtIndex:)
                                         customSelector:@selector(uninitIIndex:)
                                                    error:nil];
    // 越界：可变数组
    [objc_getClass("__NSArrayM") systemSelector:@selector(objectAtIndexedSubscript:)
                               customSelector:@selector(mutableArray_safe_objectAtIndexedSubscript:)
                                          error:nil];
    // 越界vs插入：可变数插入nil，或者插入的位置越界
    [objc_getClass("__NSArrayM") systemSelector:@selector(insertObject:atIndex:)
                               customSelector:@selector(safeInsertObject:atIndex:)
                                          error:nil];
    // 插入：可变数插入nil
    [objc_getClass("__NSArrayM") systemSelector:@selector(addObject:)
                                 customSelector:@selector(safeAddObject:)
                                          error:nil];

    
}

- (id)safe_arrObjectIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        NSLog(@"this is crash, [__NSArrayI] check index (objectAtIndex:)") ;
        return nil;
    }
    return [self safe_arrObjectIndex:index];
}
- (id)mutableArray_safe_objectAtIndexedSubscript:(NSInteger)index{
    if (index >= self.count || index < 0) {
        NSLog(@"this is crash, [__NSArrayM] check index (objectAtIndexedSubscript:)") ;
        return nil;
    }
    return [self mutableArray_safe_objectAtIndexedSubscript:index];
}
- (id)singleObjectIndex:(NSUInteger)idx{
    if (idx >= self.count) {
        NSLog(@"this is crash, [__NSSingleObjectArrayI] check index (objectAtIndex:)") ;
        return nil;
    }
    return [self singleObjectIndex:idx];
}
- (id)uninitIIndex:(NSUInteger)idx{
    if ([self isKindOfClass:objc_getClass("__NSPlaceholderArray")]) {
        NSLog(@"this is crash, [__NSPlaceholderArray] check index (objectAtIndex:)") ;
        return nil;
    }
    return [self uninitIIndex:idx];
}
- (id)safeObjectIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        NSLog(@"this is crash, [__NSArrayM] check index (objectAtIndex:)") ;
        return nil;
    }
    return [self safeObjectIndex:index];
}
- (void)safeInsertObject:(id)object atIndex:(NSUInteger)index{
    if (index>self.count) {
        NSLog(@"this is crash, [__NSArrayM] check index (insertObject:atIndex:)") ;
        return ;
    }
    if (object == nil) {
        NSLog(@"this is crash, [__NSArrayM] check object == nil (insertObject:atIndex:)") ;
        return ;
    }
    [self safeInsertObject:object atIndex:index];
}
- (void)safeAddObject:(id)object {
    if (object == nil) {
        NSLog(@"this is crash, [__NSArrayM] check index (addObject:)") ;
        return ;
    }
    [self safeAddObject:object];
}
- (id)emptyObjectIndex:(NSInteger)index {
    NSLog(@"this is crash, [__NSArray0] check index (objectAtIndex:)") ;
    return nil;
}


@end
