//
//  AppState.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/26/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "AppState.h"

static NSString* const kKeyForSiteName = @"com.adrianboyko.xerocraft.Site";
static NSString* const kKeyForServer = @"com.adrianboyko.xerocraft.Server";
static NSString* const kKeyForMyCardString = @"com.adrianboyko.xerocraft.MyCardString";
static NSString* const kKeyForMostRecentLocation = @"com.adrianboyko.xerocraft.MostRecentLocation";

@implementation AppState

+ (id)sharedInstance { 
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - VALIDATION

+ (BOOL)isValidCardString:(NSString*)str {
    NSString *expression = @"^[-_a-zA-Z0-9]{32}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    return [predicate evaluateWithObject:str];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - SITE NAME

- (NSString*) siteName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyForSiteName];
}


- (void)setSiteName:(NSString *)siteName {
    NSUserDefaults* def = NSUserDefaults.standardUserDefaults;
    if (siteName == nil) [def removeObjectForKey:kKeyForSiteName];
    else [def setObject:siteName forKey:kKeyForSiteName];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - SERVER

- (NSString*) server {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyForServer];
}


- (void)setServer:(NSString *)server {
    NSUserDefaults* def = NSUserDefaults.standardUserDefaults;
    if (server == nil) [def removeObjectForKey:kKeyForServer];
    else [def setObject:server forKey:kKeyForServer];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - MY CARD STRING

- (NSString*) myCardString {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyForMyCardString];
}


- (void)setMyCardString:(NSString *)myCardString {
    NSUserDefaults* def = NSUserDefaults.standardUserDefaults;
    if (myCardString == nil) [def removeObjectForKey:kKeyForMyCardString];
    else [def setObject:myCardString forKey:kKeyForMyCardString];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - MOST RECENT LOCATION

//TODO: Rename mostRecentLocation -> locationCurrentlyOpen

- (NSNumber*) mostRecentLocation {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyForMostRecentLocation];
}

- (void)setMostRecentLocation:(NSNumber *)mostRecentLocation {
    NSUserDefaults* def = NSUserDefaults.standardUserDefaults;
    if (mostRecentLocation == nil) [def removeObjectForKey:kKeyForMostRecentLocation];
    else [def setObject:mostRecentLocation forKey:kKeyForMostRecentLocation];
}

@end
