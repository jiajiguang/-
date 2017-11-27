# QRCode
Objective-C 使用iOS 原生库来实现二维码条形码扫描、图片二维码识别、生成二维码
1>二维码、条形码的扫描主要使用类:
        AVCaptureDevice,
        AVCaptureDeviceInput,
        AVCaptureMetafataOutput,
        AVCaptureSession,
        AVCaptureVideoPreviewLayer

2>识别图片中的二维码使用CIDetector,CIQRCodeFeature

3>根据字符串生成对应的二维码使用CIFilter
