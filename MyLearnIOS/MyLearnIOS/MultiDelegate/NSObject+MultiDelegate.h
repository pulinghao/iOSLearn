//
//  NSObject+MultiDelegate.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//


#import <Foundation/Foundation.h>
#import "MultiDelegateOC.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MultiDelegate)

@property (nonatomic, strong) MultiDelegateOC *multiDelegate;

- (void)addMultiDelegate:(id)delegate;
- (void)addDelegate:(id)delegate beforeDelegate:(id)otherDelegate;
- (void)addDelegate:(id)delegate afterDelegate:(id)otherDelegate;

- (void)removeMultiDelegate:(id)delegate;
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END
