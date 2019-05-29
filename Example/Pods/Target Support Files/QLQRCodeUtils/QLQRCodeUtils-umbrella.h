#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QLQRCodeAreaView.h"
#import "QLQRCodeBackgroundView.h"
#import "QLQRCodeUtils.h"
#import "QLQRCodeViewController.h"
#import "UIImage+QLGeneratorQrCode.h"

FOUNDATION_EXPORT double QLQRCodeUtilsVersionNumber;
FOUNDATION_EXPORT const unsigned char QLQRCodeUtilsVersionString[];

