//
//  NSObject+MyKVO.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MyKVO)

// 添加观察者
- (void)gv_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

// 删除观察者
- (void)gv_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;


@end

NS_ASSUME_NONNULL_END
