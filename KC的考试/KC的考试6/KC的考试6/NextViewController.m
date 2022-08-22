//
//  NextViewController.m
//  KC的考试6
//
//  Created by pulinghao on 2022/8/20.
//

#import "NextViewController.h"

typedef void(^Study)();
@interface Student : NSObject
@property (copy , nonatomic) NSString *name;
@property (copy , nonatomic) Study study;
@end

@implementation Student



@end


@interface NextViewController ()

@property (copy,nonatomic) NSString *name;
@property (strong, nonatomic) Student *stu;


@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Student *student = [[Student alloc]init];
        
    self.name = @"halfrost";
    self.stu = student;
    
    student.study = ^{
        NSLog(@"my name is = %@",self.name);
    };
    
    student.study();
}


- (void)dealloc{
    NSLog(@"next dealloc");
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
