//
//  ViewController.m
//  JSDemo
//
//  Created by pulinghao on 2022/8/23.
//

#import "ViewController.h"
#import "Globle.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSMutableArray *actionArray;
@property (nonatomic, strong) Globle *globle;
@property (nonatomic, strong) JSValue *callValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.jsContext = [JSContext new];
    
    
    self.globle = [Globle new];
    self.globle.ownerController = self;
    
    
    self.jsContext[@"Globle"] = self.globle;
    self.actionArray = [[NSMutableArray alloc] init];
    
    [self render];
    
}

- (void)render{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UIButton" ofType:@"js"];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *jsCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    JSValue *jsValue = [self.jsContext evaluateScript:jsCode];
    for (int i = 0; i < jsValue.toArray.count; i++) {
        JSValue *subValue = [jsValue objectAtIndexedSubscript:i];
        if ([[subValue objectForKeyedSubscript:@"typeName"].toString isEqualToString:@"Label"]) {
            UILabel *label = [UILabel new];
            label.frame = CGRectMake(subValue[@"rect"][@"x"].toDouble,
                                     subValue[@"rect"][@"y"].toDouble,
                                     subValue[@"rect"][@"width"].toDouble,
                                     subValue[@"rect"][@"height"].toDouble);
            label.text = subValue[@"text"].toString;
            label.textColor = [UIColor colorWithRed:subValue[@"color"][@"r"].toDouble green:subValue[@"color"][@"g"].toDouble blue:subValue[@"color"][@"b"].toDouble alpha:subValue[@"color"][@"a"].toDouble];
            [self.view addSubview:label];
        } else if ([[subValue objectForKeyedSubscript:@"typeName"].toString isEqualToString:@"Button"]){
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(subValue[@"rect"][@"x"].toDouble,
                                     subValue[@"rect"][@"y"].toDouble,
                                     subValue[@"rect"][@"width"].toDouble,
                                     subValue[@"rect"][@"height"].toDouble);
            [button setTitle:subValue[@"text"].toString forState:UIControlStateNormal];
            button.tag = self.actionArray.count;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//            self.callValue = subValue[@"callFunc1"];
            self.callValue = [subValue objectForKeyedSubscript:@"callFunc"];
            [self.actionArray addObject:subValue[@"callFunc1"]];
            [self.view addSubview:button];
        }
    }
}

// NA Render()
// |
// JS Render() 并保存JS的方法指针
// |
// 点击NA的button，走NA的事件
// |
// 在调JS的方法指针
// |
// JS内部调NA对应类的方法

- (void)buttonAction:(UIButton *)btn{
    
    
//    JSValue *
    [self.callValue callWithArguments:@[@"JS Tom"]]; //调用JS的方法 -> JS ->NA 改变背景色
}


@end
