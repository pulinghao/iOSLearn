//
//  MultiDelegateOC.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiDelegateOC : NSObject

/**
 The array of registered delegates.
 */
@property (readonly, nonatomic) NSMutableArray* delegates;

/**
 Whether to throw an exception when the delegate method has no implementer. Default is NO;
 */
@property (nonatomic, assign) BOOL silentWhenEmpty;

- (void)addDelegate:(id)delegate;
- (void)addDelegate:(id)delegate beforeDelegate:(id)otherDelegate;
- (void)addDelegate:(id)delegate afterDelegate:(id)otherDelegate;

- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END
