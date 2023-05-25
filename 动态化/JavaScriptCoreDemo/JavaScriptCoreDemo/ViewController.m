//
//  ViewController.m
//  JavaScriptCoreDemo
//
//  Created by pulinghao on 2023/3/24.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Create a JSContext object
    JSContext *context = [[JSContext alloc] init];
    
    // Define a JavaScript function
    NSString *jsFunction = @"function add(a, b) { return a + b; }";
    
    // Evaluate the JavaScript function in the context
    [context evaluateScript:jsFunction];
    
    // Call the JavaScript function from Objective-C
    JSValue *result = [context evaluateScript:@"add(2, 3)"];
    NSLog(@"%@", [result toNumber]);
}

@end

