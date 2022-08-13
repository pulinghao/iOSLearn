//
//  TaggerPointerLearn.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/29.
//
/*
 在现在的版本中，为了保证数据安全，苹果对 Tagged Pointer 做了数据混淆，开发者通过打印指针无法判断它是不是一个Tagged Pointer，更无法读取Tagged Pointer的存储数据。

 所以在分析Tagged Pointer之前，我们需要先关闭Tagged Pointer的数据混淆，以方便我们调试程序。通过设置环境变量OBJC_DISABLE_TAG_OBFUSCATION为YES来关闭。

 （设置步骤：Edit Scheme -> Run -> Arguments -> Environment Variables -> 添加key：OBJC_DISABLE_TAG_OBFUSCATION，value：YES）
 */

#import "TaggerPointerLearn.h"
@interface TaggerPointerLearn()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy) NSString *nameStr;
 
@end

@implementation TaggerPointerLearn


- (void)testTaggerPointer
{
    self.queue = dispatch_queue_create("MY_queue", DISPATCH_QUEUE_CONCURRENT);
       
   for (int i = 0; i<10; i++) {
       dispatch_async(self.queue, ^{
           self.nameStr = [NSString stringWithFormat:@"dsggkdaasdasdshjksda"];
           NSLog(@"tagger pointer %p", self.nameStr); // 0xb000000000000012 （Tagged Pointer 标记指针）
       });
   }
}

   
- (void)touchBegin{
    
    // 不断 retian release
    // 异步并发
    // 一直在retian
    // 一直在release -1 0
    for (int i = 0; i<10; i++) {
        dispatch_async(self.queue, ^{
            self.nameStr = [NSString stringWithFormat:@"dsggkdaasdasdshjksda"];
            
            // self.nameStr 变成CFString 了
            NSLog(@"new tagger pointer %p", self.nameStr);
        });
    }
    
}
@end
