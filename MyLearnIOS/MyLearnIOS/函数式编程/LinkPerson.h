//
//  LinkPerson.h
//  MyLearnIOS
//
//  Created by pulinghao on 2022/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LinkPerson : NSObject


- (LinkPerson *(^)())runBlk;

- (LinkPerson *(^)())studyBlk;

@end


@interface Calculator : NSObject
@property (nonatomic, assign) int result;
- (Calculator *)calculate:(int (^)(int result))calculate;
- (BOOL)equal:(BOOL (^)(int result))operation;
@end

NS_ASSUME_NONNULL_END
