//
//  NetworkViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/2/11.
//

#import "NetworkViewController.h"

@interface NetworkViewController ()<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sendRequest];
}

- (void)sendRequest{
    //创建请求
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置request的缓存策略（决定该request是否要从缓存中获取）
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    //创建配置（决定要不要将数据和响应缓存在磁盘）
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    //生成任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    //创建的task是停止状态，需要我们去启动
    [task resume];
}
//1.接收到服务器响应的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    NSLog(@"接收响应");
    //必须告诉系统是否接收服务器返回的数据
    //默认是completionHandler(NSURLSessionResponseAllow)
    //可以再这边通过响应的statusCode来判断否接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}
//2.接受到服务器返回数据的时候调用,可能被调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"接收到数据");
    //一般在这边进行数据的拼接，在方法3才将完整数据回调
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}
//3.请求完成或者是失败的时候调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSLog(@"请求完成或者是失败");
    //在这边进行完整数据的解析，回调
}

//4.将要缓存响应的时候调用（必须是默认会话模式，GET请求才可以）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
    //可以在这边更改是否缓存，默认的话是completionHandler(proposedResponse)
    //不想缓存的话可以设置completionHandler(nil)
    completionHandler(proposedResponse);
}


- (void)sendByBlock
{
    NSURL *url = [NSURL URLWithString:@"http://www.connect.com/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"username=Tom&pwd=123" dataUsingEncoding:NSUTF8StringEncoding];

    //使用全局的会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 通过request初始化task
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
     }];
    //创建的task是停止状态，需要我们去启动
    [task resume];
}
@end
