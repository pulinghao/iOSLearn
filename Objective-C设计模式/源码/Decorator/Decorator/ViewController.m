//
//  ViewController.m
//  Decorator
//
//  Created by pulinghao on 2021/7/30.
//

#import "ViewController.h"
#import "UIImage+Transform.h"
#import "UIImage+Shadow.h"
#import "ImageTransformFilter.h"
#import "ImageShadowFilter.h"
#import "DecoratorView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    // load the original image
    UIImage *image = [UIImage imageNamed:@"Image.png"];
    
   
    // create a transformation
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(-M_PI / 4.0);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(-image.size.width / 2.0,
                                                                            image.size.height / 8.0);
    CGAffineTransform finalTransform = CGAffineTransformConcat(rotateTransform, translateTransform);
    
    // a true subclass approach
    id <ImageComponent> transformedImage =[[ImageTransformFilter alloc] initWithImageComponent:image
                                                                                       transform:finalTransform];
      id <ImageComponent> finalImage = [[ImageShadowFilter alloc] initWithImageComponent:transformedImage];
    
    // a category approach
    // add transformation
//    UIImage *transformedImage = [image imageWithTransform:finalTransform];
    
    // add shadow
//    id <ImageComponent> finalImage = [transformedImage imageWithDropShadow];

    // category approach in one line
    //id <ImageComponent> finalImage = [[image imageWithTransform:finalTransform] imageWithDropShadow];
    
    
    // create a new image view
    // with a filtered image
      DecoratorView *decoratorView = [[DecoratorView alloc] initWithFrame:[self.view bounds]];
    [decoratorView setImage:finalImage];
    [self.view addSubview:decoratorView];
}


@end
