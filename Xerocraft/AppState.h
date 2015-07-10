//
//  AppState.h
//  Xerocraft
//
//  Created by Adrian Boyko on 6/26/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppState : NSObject

+ (AppState*)sharedInstance;
+ (BOOL)isValidCardString:(NSString*)str;

@property (nonatomic, copy) NSString* myCardString;
@property (nonatomic, copy) NSString* server;
@property (nonatomic, copy) NSString* siteName;
@property (nonatomic, copy) NSNumber* mostRecentLocation;

@end
