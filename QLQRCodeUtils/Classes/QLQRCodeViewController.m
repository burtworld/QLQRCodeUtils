//
//  QLQRCodeViewController.m
//  QLQRCodeUtils
//
//  Created by Paramita on 2018/1/18.
//  Copyright © 2018年 Paramita. All rights reserved.
//

#import "QLQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QLQRCodeAreaView.h"
#import "QLQRCodeBackgroundView.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define SCAN_WIDTH      220.0f
#define SCAN_HEIGHT     220.0f
#define SCAN_AREA       CGRectMake((screen_width - SCAN_WIDTH)/2, (screen_height - SCAN_HEIGHT)/2, SCAN_WIDTH, SCAN_HEIGHT)

@interface QLQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (assign, nonatomic) BOOL navigationIsHidden;
@end

@implementation QLQRCodeViewController {
    AVCaptureDevice * _device;
    AVCaptureDeviceInput * _input;
    AVCaptureMetadataOutput * _output;
    AVCaptureSession * _session;
    AVCaptureVideoPreviewLayer * _preview;
    QLQRCodeAreaView * _scanAreaView;//扫描区域视图
    CAShapeLayer *cropLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //扫描区域
    CGRect areaRect = SCAN_AREA;

    //设置扫描区域
    _scanAreaView = [[QLQRCodeAreaView alloc]initWithFrame:areaRect];
    [self.view addSubview:_scanAreaView];
    
    //提示文字
    UILabel *label = [UILabel new];
    label.text = @"将二维码放入框内，立即开始扫描";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.frame = CGRectMake((screen_width - label.frame.size.width)/2, CGRectGetMaxY(_scanAreaView.frame) + 20, label.frame.size.width, label.frame.size.height);
    [self.view addSubview:label];
    
    //返回键
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame = CGRectMake(12, 26, 42, 42);
    [backbutton setBackgroundImage:[QLQRCodeAreaView bundleImageWithName:@"back"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbutton];
    
    //相册键
//    UIButton *photobutton = [UIButton buttonWithType:UIButtonTypeCustom];
//    photobutton.frame = CGRectMake(screen_width - 42 - 12, 26, 42, 42);
//    [photobutton setTitle:@"相册" forState:UIControlStateNormal];
//    [photobutton addTarget:self action:@selector(showAlbum:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:photobutton];
}

- (void)clickBackButton {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupCamera
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self setupDeivce];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域 空间转换
    CGFloat top = ((screen_height - SCAN_HEIGHT)/2)/screen_height;
    CGFloat left = ((screen_width - SCAN_WIDTH)/2)/screen_width;
    CGFloat width = SCAN_WIDTH/screen_width;
    CGFloat height = SCAN_HEIGHT/screen_height;
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode AVMetadataObjectTypeEAN13Code,
    

    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                      AVMetadataObjectTypeEAN8Code,
                                      AVMetadataObjectTypeUPCECode,
                                      AVMetadataObjectTypeCode39Code,
                                      AVMetadataObjectTypeCode39Mod43Code,
                                      AVMetadataObjectTypeCode93Code,
                                      AVMetadataObjectTypeCode128Code,
                                      AVMetadataObjectTypePDF417Code]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}

- (void)setupDeivce {
    if (_device) {
        if ([_device lockForConfiguration:nil])
        {
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];
        }
    }
}

- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    [cropLayer setNeedsDisplay];
    [self.view.layer addSublayer:cropLayer];
}

- (void)showAlbum:(UIButton *)btn {
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count>0) {
        [_session stopRunning];//停止扫描
        [_scanAreaView stopAnimaion];//暂停动画
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        if (_delegate && [_delegate respondsToSelector:@selector(onQRCodeScaned:)]) {
            [_delegate onQRCodeScaned:metadataObject.stringValue];
        }
        [self clickBackButton];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationIsHidden = self.navigationController.navigationBarHidden;
    if (!self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    [self setCropRect:SCAN_AREA];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupCamera];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = self.navigationIsHidden;
    [_scanAreaView stopAnimaion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
