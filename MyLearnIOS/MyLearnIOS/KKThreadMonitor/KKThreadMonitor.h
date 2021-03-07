//
//  KKThreadMonitor.h
//  KKMagicHook
//
//  Created by 吴凯凯 on 2020/4/11.
//  Copyright © 2020 吴凯凯. All rights reserved.
//  这是一个检测线程数量的库

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKThreadMonitor : NSObject

+ (void)startMonitor;

@end

NS_ASSUME_NONNULL_END
