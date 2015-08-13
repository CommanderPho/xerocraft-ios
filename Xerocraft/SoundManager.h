//
//  SoundManager.h
//  Xerocraft
//
//  Created by Adrian Boyko on 8/12/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

+ (SoundManager*)sharedInstance;

- (void)playSound:(NSString*)soundResourceName;

@end
