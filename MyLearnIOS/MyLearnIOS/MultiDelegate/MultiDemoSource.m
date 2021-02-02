//
//  MultiDemoSource.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//  

#import "MultiDemoSource.h"

@implementation MultiDemoSource

- (void)getId
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(getId)])
    {
        NSNumber *d = [self.delegate getId];
        NSLog(@"Real number is %@",d);
    }
}

- (void)getInt
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(getInt)])
    {
        int d = [self.delegate getInt];
        NSLog(@"Real number is %d",d);
    }
}
- (void)getNoReturn
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(getNoReturn)])
    {
        [self.delegate getNoReturn];
    }
}

@end
