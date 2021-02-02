//
//  MultiDelegateVC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import "MultiDelegateVC.h"
#import "NSObject+MultiDelegate.h"
#import "MultiDemoSource.h"
#import "MutiDelegateDemo.h"
#import "MutiDelegateDemo2.h"
@interface MultiDelegateVC ()

@property (strong, nonatomic) MultiDemoSource *source;
@property (strong, nonatomic) MutiDelegateDemo *demo1;
@property (strong, nonatomic) MutiDelegateDemo2 *demo2;

@end

@implementation MultiDelegateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *returnId = [[UIButton alloc]initWithFrame:CGRectMake(70, 200, 100, 44)];
    returnId.backgroundColor = [UIColor lightGrayColor];
    [returnId setTitle:@"Return id" forState:UIControlStateNormal];
    [returnId setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [returnId addTarget:self action:@selector(returnId:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnId];
    
    UIButton *returnInt = [[UIButton alloc]initWithFrame:CGRectMake(200, 200, 100, 44)];
    returnInt.backgroundColor = [UIColor lightGrayColor];
    [returnInt setTitle:@"Return int" forState:UIControlStateNormal];
    [returnInt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [returnInt addTarget:self action:@selector(returnInt:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnInt];
    
    UIButton *getNoReturn = [[UIButton alloc]initWithFrame:CGRectMake(70, 300, 100, 44)];
    getNoReturn.backgroundColor = [UIColor lightGrayColor];
    [getNoReturn setTitle:@"no return" forState:UIControlStateNormal];
    [getNoReturn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [getNoReturn addTarget:self action:@selector(getNoReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getNoReturn];
    
    self.source = [[MultiDemoSource alloc]init];
    self.source.delegate = (id)self.source.multiDelegate;
    self.demo1 = [[MutiDelegateDemo alloc]init];
    self.demo2 = [[MutiDelegateDemo2 alloc]init];
    
    // 由Source发布给各自的delegate
    [self.source addMultiDelegate:self.demo1];
    [self.source addMultiDelegate:self.demo2];
}

- (void)returnId:(id)sender
{
    [self.source getId];
}

- (void)returnInt:(id)sender
{
    [self.source getInt];
}

- (void)getNoReturn:(id)sender
{
    [self.source getNoReturn];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
