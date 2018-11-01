//
//  QLQRCodeAreaView.m
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import "QLQRCodeAreaView.h"

@interface QLQRCodeAreaView()
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGPoint position;
@property (assign, nonatomic) BOOL isDown;
@property (strong, nonatomic) UIImageView *lineView;
@end

@implementation QLQRCodeAreaView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.backgroundColor = [UIColor clearColor];
    UIImageView *areaView = [[UIImageView alloc]initWithImage:[QLQRCodeAreaView bundleImageWithName:@"scanArea"]];
    areaView.frame = self.bounds;
    [self addSubview:areaView];
    
    _lineView = [[UIImageView alloc]initWithImage:[QLQRCodeAreaView bundleImageWithName:@"line"]];
    _lineView.frame = CGRectMake(0, 2, self.frame.size.width, 2);
    [self addSubview:_lineView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
    
}

- (void)moveLine {
    CGPoint newPosition = self.position;
    if (_isDown) {
        newPosition.y++;
        if (newPosition.y >= self.frame.size.height) {
            _isDown = NO;
        }
    }else{
        newPosition.y--;
        if (newPosition.y <= 0) {
            _isDown = YES;
        }
    }
    self.position = newPosition;
    _lineView.frame = CGRectMake(newPosition.x, newPosition.y, _lineView.frame.size.width, _lineView.frame.size.height);
}


+ (UIImage *)bundleImageWithName:(NSString *)imgName {
    UIImage * image = [UIImage imageNamed:imgName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
//    NSString *name = [@"QLQRCodeUtils.bundle" stringByAppendingPathComponent:imgName];
//    UIImage * image = [UIImage imageNamed:name];
    return image ? image : [UIImage imageNamed:imgName];
}

-(void)startAnimaion{
    [self.timer setFireDate:[NSDate date]];
}

-(void)stopAnimaion{
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)dealloc {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
