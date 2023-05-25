//
//  ViewController.m
//  JSBridge
//
//  Created by pulinghao on 2023/3/24.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>

@interface ViewController ()<WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"hello"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *htmlUrl = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"hello"]) {
        NSLog(@"%@", message.body);
    }
}

- (BOOL)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:@"jsbridge"]) {
        NSString *host = url.host;
        if ([host isEqualToString:@"showToast"]) {
            NSString *text = [self getParameterFromUrl:url.absoluteString paramName:@"text"];
            NSLog(@"%@", text);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return YES;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    return YES;
}

- (NSString *)getParameterFromUrl:(NSString *)url paramName:(NSString *)paramName {
    NSArray *components = [url componentsSeparatedByString:@"?"];
    if (components.count > 1) {
        NSString *query = components[1];
        NSArray *params = [query componentsSeparatedByString:@"&"];
        for (NSString *param in params) {
            NSArray *keyValue = [param componentsSeparatedByString:@"="];
            if (keyValue.count == 2) {
                NSString *key = keyValue[0];
                NSString *value = keyValue[1];
                if ([key isEqualToString:paramName]) {
                    return value;
                }
            }
        }
    }
    return nil;
}

@end
