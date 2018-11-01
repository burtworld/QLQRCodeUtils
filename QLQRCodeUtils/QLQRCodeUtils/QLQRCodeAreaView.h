//
//  QLQRCodeAreaView.h
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLQRCodeAreaView : UIView
- (void)startAnimaion;
- (void)stopAnimaion;
+ (UIImage *)bundleImageWithName:(NSString *)imgName;
@end
