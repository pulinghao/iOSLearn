//
//  MyProxy.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyProxy : NSProxy{

}


+ (instancetype)proxyWithObj:(id)obj;

@end

@interface MyDog : NSObject

-(NSString *)barking:(NSInteger)months;

- (void)test;

@end

NS_ASSUME_NONNULL_END
