//
//  ViewController.m
//  Image
//
//  Created by pulinghao on 2022/7/19.
// https://www.jianshu.com/p/aeb0b9129fcd
// https://www.toutiao.com/article/6569037697183121934/?wid=1642588854174
#import "ViewController.h"

#import <ImageIO/ImageIO.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView *firstImage;
@property (nonatomic, strong) UIImageView *secondImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIImage *img = BMThemeImage(@"npc");
    NSString *fileName = @"Mount";

    NSString *thumbnailFile = [NSString stringWithFormat:@"%@/%@.jpeg", [[NSBundle mainBundle] resourcePath], fileName];

    UIImage *image = [UIImage imageWithContentsOfFile:thumbnailFile];
    
    float scale = 0.2;
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *resizedImage = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
    
    _firstImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    [_firstImage setImage:resizedImage];
//    [_firstImage sizeToFit];
    [self.view addSubview:_firstImage];
    
//    NSString *fileName2 = @"tiantian.png";
//    NSString *thumbnailFile2 = [NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], fileName2];
    NSURL *url = [NSURL fileURLWithPath:thumbnailFile];  //必须用fileURLWithPath接口
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource == NULL) {
        NSLog(@"image Source is NULL");
    }
    //从已经加载到内存的图片，来创建
//    NSData *imageData = UIImagePNGRepresentation(image);
//    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    int maxPixelSize = self.view.frame.size.width;
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
        (__bridge id)kCGImageSourceCreateThumbnailWithTransform : @YES,
        (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
        (__bridge id)kCGImageSourceThumbnailMaxPixelSize : @(maxPixelSize)
    };
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage *resizeImage2 = [UIImage imageWithCGImage:imageRef];
    
    _secondImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 200)];
    [_secondImage setImage:resizeImage2];
    [_secondImage sizeToFit];
    [self.view addSubview:_secondImage];
}


@end
