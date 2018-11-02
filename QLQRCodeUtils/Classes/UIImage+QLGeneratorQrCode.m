//
//  UIImage+QLGeneratorQrCode.m
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import "UIImage+QLGeneratorQrCode.h"
#define ImageSize self.bounds.size.width
@implementation UIImage (QLGeneratorQrCode)

+ (void)generatorQrCode:(NSString *)qrString size:(CGSize)size addImage:(UIImage *)image corner:(CGFloat)corner result:(void(^)(UIImage *img))block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIFilter *codeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        //每次调用都恢复其默认属性
        [codeFilter setDefaults];
        NSData *codeData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
        //设置滤镜数据
        [codeFilter setValue:codeData forKey:@"inputMessage"];
        //获得滤镜输出的图片
        CIImage *outputImage = [codeFilter outputImage];
        
        //这里的图像必须经过位图转换，不然会很模糊
        CGSize tempSize = CGSizeMake(size.width, size.height);
        if (CGSizeEqualToSize(tempSize, CGSizeZero)) {
            tempSize = CGSizeMake(220, 220);
        }
        UIImage * translateImage = [self creatUIImageFromCIImage:outputImage Size:tempSize.width];
        if (image) {
            UIImage *corneredImage = [image imageCornerRadius:corner size:CGSizeMake(tempSize.width/5, tempSize.height/5)];
            translateImage = [translateImage addSubImage:corneredImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(translateImage);
            }
        });
    });
}


+ (UIImage *)creatUIImageFromCIImage:(CIImage *)image Size:(CGFloat)size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    
    CGContextScaleCTM(contextRef, scale, scale);
    
    CGContextDrawImage(contextRef, extent, imageRef);
    
    CGImageRef  newImage = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);

    return [UIImage imageWithCGImage:newImage];
    
}

- (UIImage *)imageCornerRadius:(CGFloat)cornerRadius size:(CGSize)size {
    
    //这里是将图片进行处理，frame不能太大，否则会挡住二维码
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius] addClip];
    
    [self drawInRect:frame];
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return clipImage;
    
}

//! 添加子图片 - 中心位置
- (UIImage *)addSubImage:(UIImage *)subImage {
    UIImage * superImage = [self copy];
    CGSize superSize = superImage.size;
    CGSize subSize = subImage.size;
    
    //将两张图片绘制在一起
    UIGraphicsBeginImageContextWithOptions(superSize, YES, 0);
    [superImage drawInRect:CGRectMake(0, 0, superSize.width, superSize.height)];
    [subImage drawInRect:CGRectMake((superSize.width - subSize.width)/2, (superSize.height - subSize.height)/2, subImage.size.width, subImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}

+ (NSArray *)detectQRCodeFromView:(UIView *)view {
    //截图 再读取
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self detectQRCodeFromImage:image];
}

+ (NSArray *)detectQRCodeFromImage:(UIImage *)image {
    image = [self renderImage:image];
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}]; // 软件渲染
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:ciContext options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];// 二维码识别
    
    NSArray *features = [detector featuresInImage:ciImage];
    if (features.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (CIQRCodeFeature *feature in features) {
            [array addObject:feature.messageString];
        }
        return array;
    }
    
    return nil;
}

#pragma mark - private
/// 将图片压缩至256
+ (UIImage *)renderImage:(UIImage *)theImage {
    UIImage* bigImage = theImage;
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth > actualHeight) {
        //宽图
        newHeight =256.0f;
        newWidth = actualWidth / actualHeight * newHeight;
    }
    else
    {
        //长图
        newWidth =256.0f;
        newHeight = actualHeight / actualWidth * newWidth;
    }
    CGRect rect =CGRectMake(0.0,0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];// scales image to rect
    theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
