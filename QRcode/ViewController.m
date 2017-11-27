//
//  ViewController.m
//  QRcode
//
//  Created by yang on 2017/11/24.
//  Copyright © 2017年 wondertek. All rights reserved.
//

#import "ViewController.h"
#import "RQCodeViewController.h"
#import <CoreImage/CoreImage.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@end

@implementation ViewController{
    UIImageView *imageV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 50);
    [btn setTitle:@"二维码扫描" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor: [UIColor greenColor]];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 200, self.view.frame.size.width-20, 50);
    [btn1 setTitle:@"选择图片识别二维码" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btn1Click:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setBackgroundColor: [UIColor greenColor]];
    
    UITextField *textF = [[UITextField alloc] init];
    textF.frame = CGRectMake(10, 300, self.view.frame.size.width-20, 50);
    textF.tag = 201711;
    textF.borderStyle = UITextBorderStyleLine;
    textF.clearButtonMode = UITextFieldViewModeWhileEditing;
    textF.placeholder = @"转二维码请在此输入";
    [self.view addSubview:textF];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(10, 360, self.view.frame.size.width-20, 50);
    [btn2 setTitle:@"生成二维码" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    [btn2 setBackgroundColor:[UIColor greenColor]];
    
    imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 430, 100, 100)];
    [self.view addSubview:imageV];
    
}

- (void)btnClick:(UIButton *)sender{
    RQCodeViewController *vc =[[RQCodeViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)btn1Click:(UIButton *)sender{
    UIImagePickerController *iamgeP = [[UIImagePickerController alloc] init];
    iamgeP.delegate = self;
    [self presentViewController:iamgeP animated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo{
    //初始化扫描，设置扫描类型、扫描质量
    CIDetector *detctor = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    //获取扫描特征
    NSArray *array = [detctor featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (array.count < 1) {
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
        return;
    }
    NSLog(@"array == %@",array);
    //得到扫描结果
    CIQRCodeFeature *feature = [array objectAtIndex:0];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:feature.messageString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)btn2Click:(UIButton *)sender{
    UITextField *textF = [self.view viewWithTag:201711];
    if (textF.text.length<1) {
        return;
    }
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSData *data = [textF.text dataUsingEncoding:NSUTF8StringEncoding];
    //使用KVC方式为filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    CIImage *image = [filter outputImage];
    
    imageV.image = [self creatNonInterpolatedUIImageFormCIImage:image withSize:100];
    
}
//生成清晰二维码
- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1. 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
