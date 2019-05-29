//
//  QLQRCodeBackgroundView.m
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import "QLQRCodeBackgroundView.h"

@implementation QLQRCodeBackgroundView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (CGRectEqualToRect(_scanArea, CGRectZero)) {
        _scanArea = CGRectMake(([UIScreen mainScreen].bounds.size.width - 218)/2, ([UIScreen mainScreen].bounds.size.height - 218)/2, 218, 218);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //填充区域颜色
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.65] set];
    
    //扫码区域上面填充
    CGRect notScanRect = CGRectMake(0, 0, self.frame.size.width, _scanArea.origin.y);
    CGContextFillRect(context, notScanRect);
    
    //扫码区域左边填充
    rect = CGRectMake(0, _scanArea.origin.y, _scanArea.origin.x,_scanArea.size.height);
    CGContextFillRect(context, rect);
    
    //扫码区域右边填充
    rect = CGRectMake(CGRectGetMaxX(_scanArea), _scanArea.origin.y, _scanArea.origin.x,_scanArea.size.height);
    CGContextFillRect(context, rect);
    
    //扫码区域下面填充
    rect = CGRectMake(0, CGRectGetMaxY(_scanArea), self.frame.size.width,self.frame.size.height - CGRectGetMaxY(_scanArea));
    CGContextFillRect(context, rect);
}


@end
