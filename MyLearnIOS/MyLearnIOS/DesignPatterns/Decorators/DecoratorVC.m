//
//  DecoratorVC.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/3/6.
//

#import "DecoratorVC.h"
#import "Hero.h"
#import "BuffDecorator.h"

@interface DecoratorVC ()

@end

@implementation DecoratorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
}

- (void)test {
    NSLog(@"----------------Galen----------------------");
    Hero *galen = [Galen new];
    galen = [[RedBuffDecorator alloc] initWithHero:galen];
    [galen blessBuff];
    galen = [[BlueBuffDecorator alloc] initWithHero:galen];
    [galen blessBuff];
    NSLog(@"----------------Timo----------------------");
    Hero *timo = [Timo new];
    timo = [[RedBuffDecorator alloc] initWithHero:timo];
    [timo blessBuff];
    timo = [[BlueBuffDecorator alloc] initWithHero:timo];
    [timo blessBuff];
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
