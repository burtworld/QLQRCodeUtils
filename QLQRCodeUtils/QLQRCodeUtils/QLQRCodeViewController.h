//
//  QLQRCodeViewController.h
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QLQRCodeViewControllerDelegate<NSObject>
- (void)onQRCodeScaned:(NSString *)qrString;
@end


@interface QLQRCodeViewController : UIViewController
@property (weak, nonatomic) id<QLQRCodeViewControllerDelegate>delegate;
@end
