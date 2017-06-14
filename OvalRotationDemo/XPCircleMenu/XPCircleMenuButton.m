//
//  XPCircleMenuButton.m
//  https://github.com/xiaopin/XPCircleMenu.git
//
//  Created by xiaopin on 2017/2/5.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPCircleMenuButton.h"

@implementation XPCircleMenuButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (nil == self.imageView.image) {
        self.imageView.frame = CGRectZero;
        self.titleLabel.frame = self.bounds;
        self.titleLabel.numberOfLines = 0;
    } else if (nil == self.titleLabel.text || 0 == self.titleLabel.text.length) {
        self.imageView.frame = self.bounds;
        self.titleLabel.frame = CGRectZero;
    } else {
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat height = CGRectGetHeight(self.frame);
        CGFloat textHeight = [self.titleLabel.text boundingRectWithSize:CGSizeMake(width, height)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                                context:NULL].size.height;
        CGFloat lineHeight = 5.0;
        self.titleLabel.numberOfLines = 2;
//        self.imageView.frame = CGRectMake(0.0, 0.0, width, height-textHeight-lineHeight);
        self.titleLabel.frame = CGRectMake(0.0, CGRectGetMaxY(self.imageView.frame)+lineHeight, width, textHeight);
        CGPoint center = self.imageView.center;
        center.x = self.titleLabel.center.x;
        self.imageView.center = center;
        
//        self.backgroundColor=[UIColor blueColor];
//        self.titleLabel.backgroundColor=[UIColor redColor];
    }
}

@end
