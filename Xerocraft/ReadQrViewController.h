//
//  ReadQrViewController.h
//  Xerocraft
//
//  Created by Adrian Boyko on 6/22/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ReadQrDelegate.h"

@interface ReadQrViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) id<ReadQrDelegate> delegate;

@end

