//
//  AutoReleasePoolLearn.h
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoReleasePoolLearn : NSObject

@property (nonatomic, strong) NSString *myStr;

- (void)withoutAutoreleasepoolClick;

@end

NS_ASSUME_NONNULL_END
