//
//  main.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "KKThreadMonitor.h"
#import "RuntimeLearn.h"
#import "RunLoopLearn.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
//        [KKThreadMonitor startMonitor];
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
