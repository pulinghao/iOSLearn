//
//  MultiDemoSource.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//  在这里面写delegate，对外只暴露他的delegate

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MultiDemoSourceDelegate <NSObject>

- (NSNumber *)getId;
- (int )getInt;
- (void)getNoReturn;

@end

@interface MultiDemoSource : NSObject

@property (nonatomic, weak) id<MultiDemoSourceDelegate> delegate;


- (void)getId;
- (void)getInt;
- (void)getNoReturn;

@end

NS_ASSUME_NONNULL_END
