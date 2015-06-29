//
//  ReadQrViewController.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/22/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadQrVC.h"

@interface ReadQrVC ()

@property (weak, nonatomic)   IBOutlet UIView *camView;

@property (nonatomic, strong) NSString *lastStringRead;
@property (nonatomic, assign) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ReadQrVC

@synthesize isReading = _isReading;

- (NSObject*)json {
    if (self.lastStringRead == nil) return nil;
    NSData *jsonData = [self.lastStringRead dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSObject *result = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    return err ? nil : result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _captureSession = nil;
    _isReading = NO;
    _lastStringRead = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isReading = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.isReading = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isReading {
    return _isReading;
}

- (void)setIsReading:(BOOL)newVal {
    if (_isReading==YES && newVal==NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isReading = NO;
            [self stopReading];
            [self.view setNeedsDisplay];
        });
    }
    else if (_isReading==NO && newVal==YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isReading = YES;
            [self startReading];
            [self.view setNeedsDisplay];
        });
    }
    else if (_isReading==newVal) {
        // NSLog(@"isReading setter called with %hhd when property is already %hhd", newVal, _isReading);
    }
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice =
        [AVCaptureDevice
            defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input =
        [AVCaptureDeviceInput
            deviceInputWithDevice:captureDevice
            error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput =
        [[AVCaptureMetadataOutput alloc] init];
    
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer =
        [[AVCaptureVideoPreviewLayer alloc]
            initWithSession:self.captureSession];
    
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.camView.layer.bounds];
    [self.camView.layer addSublayer:self.videoPreviewLayer];
    
    [self.captureSession startRunning];
    
    return YES;
}

- (void)stopReading {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
}

-(void) captureOutput:(AVCaptureOutput*)captureOutput
    didOutputMetadataObjects:(NSArray*)metadataObjects
    fromConnection:(AVCaptureConnection*)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            // Ignore duplicate notifications:
            if ([metadataObj.stringValue isEqualToString:self.lastStringRead]) return;
            
            self.lastStringRead = metadataObj.stringValue;
            BOOL continueCapture = [self.delegate qrReader:self readString:metadataObj.stringValue];
            if (!continueCapture) self.isReading = NO;
        }
    }
}

@end
