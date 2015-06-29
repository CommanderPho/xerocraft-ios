//
//  ReadQrDelegate.h
//  Xerocraft
//
//  Created by Adrian Boyko on 6/25/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReadQrVC;

@protocol ReadQrDelegate <NSObject>

@required

// Delegate should return YES if scanning for codes should continue, else NO.
- (BOOL)qrReader:(ReadQrVC*)qrReader readString:(NSString*)qrDataString;

@end

