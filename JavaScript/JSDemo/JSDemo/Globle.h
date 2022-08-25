//
//  Globle.h
//  JSDemo
//
//  Created by pulinghao on 2022/8/23.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol GlobleProtocol <JSExport>

- (void)changeBackgroundColor:(JSValue *)value;

- (void)doSomething:(JSValue *)value;

@end

@interface Globle : NSObject <GlobleProtocol>

@property (nonatomic, weak) UIViewController *ownerController;


@end

NS_ASSUME_NONNULL_END
