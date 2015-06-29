//
//  ReadQrDelegate.h
//  Xerocraft
//
//  Created by Adrian Boyko on 6/25/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReadQrDelegate <NSObject>

@required

// Delegate should return YES if scanning for codes should continue, else NO.
- (BOOL)processString:(NSString*)qrDataString;

@end

