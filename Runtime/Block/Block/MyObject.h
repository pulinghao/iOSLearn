//
//  MyObject.h
//  Block
//
//  Created by pulinghao on 2022/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^blk_t)(void);

@interface MyObject : NSObject
{
    blk_t blk_;
}
@end

NS_ASSUME_NONNULL_END
