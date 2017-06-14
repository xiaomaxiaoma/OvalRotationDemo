//
//  ViewController.m
//  OvalRotationDemo
//
//  Created by 马方会 on 2017/6/14.
//  Copyright © 2017年 马方会. All rights reserved.
//

#import "ViewController.h"
#import "XPCircleMenuView.h"
#import "XPCircleMenuItem.h"
@interface ViewController ()
{
    
    ZZCircleProgress *circle3;
    XPCircleMenuView *menuView;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    menuView = [[XPCircleMenuView alloc] init];
    menuView.frame = CGRectMake(-50.0*[UIScreen mainScreen].bounds.size.width/375, 0.0, [UIScreen mainScreen].bounds.size.width+100*[UIScreen mainScreen].bounds.size.width/375, [UIScreen mainScreen].bounds.size.width+100*[UIScreen mainScreen].bounds.size.width/375);
    //    menuView.backgroundColor = [UIColor orangeColor];
    menuView.innerCircleRadius = 100*[UIScreen mainScreen].bounds.size.width/375;//([UIScreen mainScreen].bounds.size.width-200)/2;
    menuView.borderLayoutMargin = 0.0;
    menuView.autoAdjustPosition = NO;
    menuView.defaultOffsetRadians = -M_PI_2-M_PI_4+(M_PI_4)*2;//M_PI/2/2+M_PI; 调整翻转初始的弧度
    //    menuView.delegate = self;
    menuView.menuTextColor = [self hexStringToColor:@"b4b4b4" thisAlpha:1];
    menuView.menuItems = @[
                           [XPCircleMenuItem itemWithIcon:@"11" title:@"执行总裁\n10000单"],
                           [XPCircleMenuItem itemWithIcon:@"11" title:@"系统领导人\n10000单"],
                           [XPCircleMenuItem itemWithIcon:@"11" title:@"体系领导人\n10000单"],
                           [XPCircleMenuItem itemWithIcon:@"22" title:@"联合发起人\n10000单"],
                           [XPCircleMenuItem itemWithIcon:@"33" title:@"消费合伙人\n10000单"],
                           [XPCircleMenuItem itemWithIcon:@"33" title:@"U联宝会员"],
                           [XPCircleMenuItem itemWithIcon:@"" title:@""],
                           [XPCircleMenuItem itemWithIcon:@"" title:@""],
                           
                           ];
    
    [self.view addSubview:menuView];
    
    
    
    //    [self initCircles];
    [self performSelector:@selector(initCircles) withObject:nil afterDelay:0.00];
    //
    
    
    
    
    //
}
//初始化
- (void)initCircles {
    
    
    CGFloat m34 = 800;
    
    CGFloat value =-45;//（控制翻转角度）
    
    CGPoint point = CGPointMake(0.5, 1.0);//设定翻转时的中心点，0.5为视图layer的正中
    
    CATransform3D transfrom = CATransform3DIdentity;
    
    transfrom.m34 = 1.0 / m34;
    
    CGFloat radiants = value / 360.0 * 2 * M_PI;
    
    transfrom = CATransform3DRotate(transfrom, radiants, 1.0f, 0.0f, 0.0f);//(后面3个 数字分别代表不同的轴来翻转，本处为x轴)
    
    
    CALayer *layer = menuView.layer;
    
    layer.anchorPoint = point;
    
    layer.transform = transfrom;
    //    layer.anchorPoint=CGPointMake(0.5, 0.5);
    
    
    
}
- (UIColor*)hexStringToColor:(NSString*)stringToConvert thisAlpha:(float)colorAlpha
{
    
    
    NSString* cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6)
        return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* rString = [cString substringWithRange:range];
    range.location = 2;
    NSString* gString = [cString substringWithRange:range];
    range.location = 4;
    NSString* bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:colorAlpha];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
