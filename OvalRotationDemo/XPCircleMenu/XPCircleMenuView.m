//
//  XPCircleMenuView.m
//  https://github.com/xiaopin/XPCircleMenu.git
//
//  Created by xiaopin on 2017/2/4.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPCircleMenuView.h"
#import "XPCircleMenuButton.h"
#import "XPCircleMenuItem.h"
//弧度转角度
#define RADIANS_TO_ANGLE(radians) ((radians)*(180.0/M_PI))
//角度转弧度
#define ANGLE_TO_RADIANS(angle) ((angle)/180.0*M_PI)

@interface XPCircleMenuView ()<UIGestureRecognizerDelegate>

/// 菜单按钮容器视图
@property (nonatomic, strong) UIView *buttonContainerView;
/// 触摸点
@property (nonatomic, assign) CGPoint touchPoint;
/// 记录每个按钮的旋转弧度
@property (nonatomic, strong) NSMutableDictionary *radiansMap;
/// 记录当前滑动手势偏移弧度
@property (nonatomic, assign) float offsetRadians;
/// 菜单半径
@property (nonatomic, assign) CGFloat menuRadius;
/// 记录总共滑动手势偏移弧度
@property (nonatomic, assign) float alloffsetRadians;
@property (nonatomic,assign) CGFloat  isfirst;

@end


@implementation XPCircleMenuView

@synthesize identifierImageView = _identifierImageView;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isfirst=1;
        [self configureUserInterface];
        
      
        
    }
    return self;
}
-(void)drawRect:(CGRect)rect{

    [super drawRect:rect];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureUserInterface];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat maxWidth = CGRectGetWidth(self.frame);
    CGFloat maxHeight = CGRectGetHeight(self.frame);
    _menuRadius = MIN(maxWidth, maxHeight)/2;
    
    

    

   // self.layer.cornerRadius = _menuRadius;
    
    _identifierImageView.frame = CGRectMake((maxWidth-_innerCircleRadius*2)/2,
                                            (maxHeight-_innerCircleRadius*2)/2,
                                            _innerCircleRadius*2,
                                            _innerCircleRadius*2);
//    _identifierImageView.layer.cornerRadius = _innerCircleRadius;
    _buttonContainerView.frame = CGRectMake(_borderLayoutMargin,
                                            _borderLayoutMargin,
                                            maxWidth-2*_borderLayoutMargin,
                                            maxHeight-2*_borderLayoutMargin);
//    _buttonContainerView.layer.cornerRadius = CGRectGetWidth(_buttonContainerView.frame)/2;
    if (_isfirst==1) {
        CGRect frrame;
        frrame.size=CGSizeMake(_menuRadius+(_menuRadius-CGRectGetWidth(_identifierImageView.frame)/2)-32*[UIScreen mainScreen].bounds.size.width/375, _menuRadius+(_menuRadius-CGRectGetWidth(_identifierImageView.frame)/2)-32*[UIScreen mainScreen].bounds.size.width/375);
        _circle3.frame=frrame;
        _circle3.center=_buttonContainerView.center;
        
        
        // 布局菜单按钮,初始化每个按钮的初始位置偏移量
        [_radiansMap removeAllObjects];
        for (NSInteger i=0,count=_buttonContainerView.subviews.count; i<count; i++) {
            NSString *key = [NSString stringWithFormat:@"%ld",i];
            double radians = (M_PI*2/count)*i+_defaultOffsetRadians;
            [_radiansMap setObject:@(radians) forKey:key];
        }
        [self adjustMenuButtonPositionWithOffsetRadians:0.0 isAnimation:NO];
    }



    
    _isfirst=2;
    
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return _menuItems.count>0;
}

//#pragma mark - Actions
//
//- (void)buttonAction:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(circleMenuView:didSelectedAtIndex:)]) {
//        NSInteger index = sender.tag;
//        [self.delegate circleMenuView:self didSelectedAtIndex:index];
//    }
//}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            _touchPoint = [sender locationInView:self];
            _offsetRadians = 0.0;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [sender locationInView:self];
            double angleBegin = [self angleWithPoint:_touchPoint];
            double angleAfter = [self angleWithPoint:point];
            NSInteger index = [self quadrantWithPoint:point];
            double radians;
            if (1==index || 4==index) {
                radians = ANGLE_TO_RADIANS(angleAfter-angleBegin);
            } else {
                radians = ANGLE_TO_RADIANS(angleBegin-angleAfter);
            }
            [self adjustMenuButtonPositionWithOffsetRadians:radians isAnimation:NO];

            _touchPoint = point;
            _offsetRadians += radians;
            _alloffsetRadians+=radians;
            _circle3.transform= CGAffineTransformMakeRotation(_alloffsetRadians);

            NSLog(@"%f",_alloffsetRadians);

        }
            break;
        case UIGestureRecognizerStateEnded:
        {
        
//            [self adjustMenuButtonPositionWithOffsetRadians:0.0 isAnimation:YES];
        }
        case UIGestureRecognizerStateCancelled: {
            if (_autoAdjustPosition) { // 需要自动调整按钮位置
                double perRadians = M_PI*2/_menuItems.count;
                double radians = 0.0;
                double offsetRadians = fmod(_offsetRadians, perRadians);
                if (offsetRadians < 0.0) { // 逆时针方向旋转
                    if (offsetRadians >= -perRadians*0.5) {
                        radians = -offsetRadians;
                    } else {
                        radians = (perRadians+offsetRadians)*-1;
                    }
                } else { // 顺时针方向旋转
                    if (offsetRadians >= perRadians*0.5) {
                        radians = perRadians - offsetRadians;
                    } else {
                        radians = -offsetRadians;
                    }
                }
                [self adjustMenuButtonPositionWithOffsetRadians:radians isAnimation:YES];
            }
            
            _offsetRadians = 0.0;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (void)configureUserInterface {
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    _innerCircleRadius = 10.0;
    _borderLayoutMargin = 10.0;
    _radiansMap = [NSMutableDictionary dictionary];
    _menuTextColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    _menuTextFont = [UIFont systemFontOfSize:11.0];
    _autoAdjustPosition = YES;
    _defaultOffsetRadians = M_PI_2;
    
    _alloffsetRadians=0;
    
    //自定义起始角度、自定义小圆点、动画从上次数值开始
    _circle3 = [[ZZCircleProgress alloc] initWithFrame:CGRectMake(0, 0, _menuRadius+(_menuRadius-CGRectGetWidth(_identifierImageView.frame)/2),_menuRadius+(_menuRadius-CGRectGetWidth(_identifierImageView.frame)/2)) pathBackColor:nil pathFillColor:[self hexStringToColor:@"fae100" thisAlpha:1] startAngle:-90 strokeWidth:4];
    _circle3.reduceValue = 135;
    _circle3.animationModel=CircleIncreaseSameTime;
    _circle3.showProgressText=NO;
    _circle3.pathBackColor=[self hexStringToColor:@"d1d1d1" thisAlpha:1];
    _circle3.increaseFromLast = YES;
    _circle3.userInteractionEnabled=NO;
    _circle3.showPoint=NO;
    _circle3.notAnimated=YES;
    _circle3.pointImage = [UIImage imageNamed:@"test_point"];
    _circle3.progress = 0.7;
//    _circle3.backgroundColor=[UIColor redColor];
    [self addSubview:_circle3];
    
    
    _buttonContainerView = [[UIView alloc] init];
    _buttonContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_buttonContainerView];
    
    _identifierImageView = [[UIImageView alloc] init];
    _identifierImageView.backgroundColor = [UIColor clearColor];
//    _identifierImageView.layer.masksToBounds = YES;
    _identifierImageView.hidden=YES;
//    _identifierImageView.backgroundColor=[UIColor greenColor];
    [self addSubview:_identifierImageView];
    
    SEL sel = @selector(panGestureRecognizerAction:);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:sel];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

/// 检测坐标点处于第几象限
- (NSInteger)quadrantWithPoint:(CGPoint)point {
    CGFloat tmpX = point.x - _menuRadius;
    CGFloat tmpY = point.y - _menuRadius;
    if (tmpX >= 0) {
        return tmpY>=0 ? 4: 1;
    }
    return tmpY>=0 ? 3 : 2;
}

/// 根据坐标点获取旋转角度值
- (double)angleWithPoint:(CGPoint)point {
    CGFloat x = point.x - _menuRadius;
    CGFloat y = point.y - _menuRadius;
    return asin(y/hypot(x, y))*180/M_PI;
}

/// 根据偏移弧度值调整按钮位置
- (void)adjustMenuButtonPositionWithOffsetRadians:(double)radians isAnimation:(BOOL)isAnimation {
    
    CGFloat containerRaduis = CGRectGetWidth(_buttonContainerView.frame)/2;
    NSInteger count = _buttonContainerView.subviews.count;
    double tmp = _innerCircleRadius+(containerRaduis-_innerCircleRadius)/2;
    CGFloat buttonWidth = (containerRaduis-_innerCircleRadius)/sqrt(2);
    
    

    
    for (NSInteger i=0; i<count-2; i++) {
        NSString *key = [NSString stringWithFormat:@"%ld",i];
        double startRadians = [_radiansMap[key] doubleValue]+radians;
        [_radiansMap setObject:@(startRadians) forKey:key];
        CGFloat centerX = containerRaduis+tmp*cos(startRadians);
        CGFloat centerY = containerRaduis+tmp*sin(startRadians);
        UIView *view = _buttonContainerView.subviews[i];
//        view.backgroundColor=[UIColor yellowColor];
        view.bounds = CGRectMake(0.0, 0.0, buttonWidth, buttonWidth);
        if (isAnimation) {
            [UIView animateWithDuration:0.25 animations:^{
                view.center = CGPointMake(centerX, centerY);
            }];
        } else {
            view.center = CGPointMake(centerX, centerY);
        }
        
    }
    
//                _circle3.transform= CGAffineTransformMakeRotation(M_PI*radians);


}

#pragma mark - setter & getter

- (void)setFrame:(CGRect)frame {
    CGFloat wh = MIN(frame.size.width, frame.size.height);
    frame.size = CGSizeMake(wh, wh);
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    CGFloat wh = MIN(bounds.size.width, bounds.size.height);
    bounds.size = CGSizeMake(wh, wh);
    [super setBounds:bounds];
}

- (void)setMenuItems:(NSArray<XPCircleMenuItem *> *)menuItems {
    _menuItems = menuItems;
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i=0, count=_menuItems.count; i<count; i++) {
        XPCircleMenuItem *item = _menuItems[i];
        XPCircleMenuButton *button = [XPCircleMenuButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:item.icon] forState:UIControlStateNormal];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setTitleColor:_menuTextColor forState:UIControlStateNormal];
        button.titleLabel.font = _menuTextFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.enabled=NO;
//        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonContainerView addSubview:button];
    }
}
-(void)setDefaultOffsetRadians:(double)defaultOffsetRadians{

    _defaultOffsetRadians=defaultOffsetRadians;
//    _circle3.reduceValue = 135;

    _circle3.startAngle=RADIANS_TO_ANGLE(defaultOffsetRadians)-135;
    
}
- (void)setMenuTextColor:(UIColor *)menuTextColor {
    _menuTextColor = menuTextColor;
    for (UIButton *button in _buttonContainerView.subviews) {
        [button setTitleColor:menuTextColor forState:UIControlStateNormal];
    }
}

- (void)setMenuTextFont:(UIFont *)menuTextFont {
    _menuTextFont = menuTextFont;
    for (UIButton *button in _buttonContainerView.subviews) {
        button.titleLabel.font = menuTextFont;
    }
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
@end
