//
//  CopyViewController.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/8/15.
//

#import "CopyViewController.h"
#import "MyCopy.h"
@interface CopyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testOneBtn;
@property (weak, nonatomic) IBOutlet UIButton *testTwoBtn;
@property (nonatomic,strong) MyCopy *myCopy;
@property (weak, nonatomic) IBOutlet UIButton *testArrayBtn;
@property (weak, nonatomic) IBOutlet UIButton *testMutableArrayBtn;

@end

@implementation CopyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myCopy = [[MyCopy alloc] init];
}


- (IBAction)onClickTestOne:(id)sender {
    
    [_myCopy testOne];
}
- (IBAction)onClickTestTwo:(id)sender {
    [_myCopy testTwo];
}
- (IBAction)onClickTestArray:(id)sender {
    NSArray *cellArray1 = @[@"1", @"2", @"3"];
    NSArray *cellArray2 = @[@"4", @"5", @"6"];
    
    NSArray *array = @[cellArray1, cellArray2];
    NSArray *arrayCopy = [array copy];
    NSArray *arrayMutableCopy = [array mutableCopy];
        
    NSArray *tempArray = array.firstObject;
    NSArray *tempArrayCopy = arrayCopy.firstObject;
    NSArray *tempArrayMutableCopy = arrayMutableCopy.firstObject;
    
    NSLog(@"不可变数组  copy 和 mutableCopy的区别");
    NSLog(@"对象地址   对象指针地址  firstObject地址  firstObject指针地址");
    NSLog(@"      array: %p , %p , %p , %p", array, &array, tempArray, &tempArray);
    NSLog(@"       copy: %p , %p , %p , %p", arrayCopy, &arrayCopy, tempArrayCopy, &tempArrayCopy);
    NSLog(@"mutalbeCopy: %p , %p , %p , %p", arrayMutableCopy, &arrayMutableCopy, tempArrayMutableCopy, &tempArrayMutableCopy);

}
- (IBAction)onClickTestMutableArray:(id)sender {
    NSArray *cellArray1 = @[@"1", @"2", @"3"];
    NSArray *cellArray2 = @[@"4", @"5", @"6"];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:@[cellArray1, cellArray2]];
    NSMutableArray *mutableArrayCopy = [mutableArray copy];
    NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
    
    NSMutableArray *tempMutableArray = mutableArray.firstObject;
    NSMutableArray *tempMutableArrayCopy = mutableArrayCopy.firstObject;
    NSMutableArray *tempMutableArrayMutableCopy = mutableArrayMutableCopy.firstObject;
    
    NSLog(@"可变数组  copy 和 mutableCopy的区别");
    NSLog(@"                 对象地址     对象指针地址  firstObject地址  firstObject指针地址");
    NSLog(@"mutableArray: %p , %p , %p , %p", mutableArray, &mutableArray, tempMutableArray, &tempMutableArray);
    NSLog(@"        copy: %p , %p , %p , %p", mutableArrayCopy, &mutableArrayCopy, tempMutableArrayCopy, &tempMutableArrayCopy);
    NSLog(@" mutalbeCopy: %p , %p , %p , %p", mutableArrayMutableCopy, &mutableArrayMutableCopy, tempMutableArrayMutableCopy, &tempMutableArrayMutableCopy);

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
