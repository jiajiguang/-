//
//  RQCodeViewController.m
//  QRcode
//
//  Created by yang on 2017/11/24.
//  Copyright © 2017年 wondertek. All rights reserved.
//

#import "RQCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface RQCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong)AVCaptureDevice *device;
@property (nonatomic,strong)AVCaptureDeviceInput  *input;
@property (nonatomic,strong)AVCaptureMetadataOutput *output;
@property (nonatomic,strong)AVCaptureSession    *session;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer  *previewLayer;


@end

@implementation RQCodeViewController{
    UIImageView *imageV;
    NSTimer     *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置四周模糊处理
    [self layerRect];
    [self setlineView];
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效区域，需要注意x，y颠倒，w，h颠倒,取值是0~1
    _output.rectOfInterest = CGRectMake((self.view.frame.size.height/2-100)/self.view.frame.size.height, (self.view.frame.size.width/2-100)/self.view.frame.size.width, 200/self.view.frame.size.height, 200/self.view.frame.size.width);
    
    _session =[[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code];
    
    //,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    [_session startRunning];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, self.view.frame.size.height-40, self.view.frame.size.width-20, 50);
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn setTitle:@"推出扫描" forState:UIControlStateNormal];
}
//设置四周区域模糊处理
- (void)layerRect{
    CAShapeLayer *shaper = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, self.view.bounds);
    CGPathAddRect(path, nil, CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 200));
    
    [shaper setFillRule:kCAFillRuleEvenOdd];
    [shaper setPath:path];
    [shaper setFillColor:[[UIColor grayColor] CGColor]];
    [shaper setOpacity:0.6];
    
    [shaper setNeedsDisplay];
    [self.view.layer addSublayer:shaper];
}
//设置上下扫描的线
- (void)setlineView{
    imageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 1)];
    [self.view addSubview:imageV];
    imageV.backgroundColor = [UIColor redColor];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)animation{
    
    if (imageV.frame.origin.y>=self.view.frame.size.height/2+100) {
        imageV.frame =CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-100, 200, 1);
    }else{
        imageV.frame =CGRectMake(self.view.frame.size.width/2-100, imageV.frame.origin.y+10, 200, 1);
    }
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if ([metadataObjects count]>0) {
        //停止扫描
        [_session stopRunning];
        [timer invalidate];
        timer = nil;
        AVMetadataMachineReadableCodeObject *code = [metadataObjects objectAtIndex:0];
        NSLog(@"扫描结果为：%@",code.stringValue);
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:code.stringValue delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [aler show];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)btnClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (BOOL)shouldAutorotate{
    return NO;
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
