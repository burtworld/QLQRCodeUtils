//
//  UIImage+QLGeneratorQrCode.h
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QLGeneratorQrCode)
//! 生成二维码，异步调用，主线程返回image
+ (void)generatorQrCode:(NSString *)qrString size:(CGSize)size addImage:(UIImage *)image corner:(CGFloat)corner result:(void(^)(UIImage *img))block;
- (UIImage *)imageCornerRadius:(CGFloat)cornerRadius size:(CGSize)size;
- (UIImage *)addSubImage:(UIImage *)subImage;
+ (NSArray *)detectQRCodeFromView:(UIView *)view;

@end
