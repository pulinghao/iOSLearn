//
//  MyLearnIOSTests.m
//  MyLearnIOSTests
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import <XCTest/XCTest.h>

#import "LockLearn.h"
@interface MyLearnIOSTests : XCTestCase

@end

@implementation MyLearnIOSTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    LockLearn *learn = [[LockLearn alloc] init];
    [self measureBlock:^{
        [learn testTwoThreadLock];
        // Put the code you want to measure the time of here.
    }];
}

@end
