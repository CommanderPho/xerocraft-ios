//
//  ViewController.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/22/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *camView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *startStopButton;

@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;


@end

@implementation ViewController

@synthesize isReading = _isReading;

- (void)viewDidLoad {
    [super viewDidLoad];
    _isReading = NO;
    _captureSession = nil;
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
            [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
            [self.statusLabel setText:@"Waiting"];
            [self.view setNeedsDisplay];
        });
    }
    else if (_isReading==NO && newVal==YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isReading = YES;
            [self startReading];
            [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
            [self.statusLabel setText:@"Watching for QR Code"];
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

- (IBAction)startStopTouch:(UIButton*)sender {
    self.isReading = !self.isReading;
}

-(void) captureOutput:(AVCaptureOutput*)captureOutput
    didOutputMetadataObjects:(NSArray*)metadataObjects
    fromConnection:(AVCaptureConnection*)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Got it!" waitUntilDone:NO];
            // TODO: send [metadataObj stringValue] to URL then segue to user info
            self.isReading = NO;
        }
    }
}

@end
