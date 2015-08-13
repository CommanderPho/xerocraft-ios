//
//  SoundManager.m
//  Xerocraft
//
//  Created by Adrian Boyko on 8/12/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SoundManager.h"

@implementation SoundManager

__strong static NSMutableDictionary* audioPlayers;

AVAudioPlayer* loadSound(NSString* resourceName) {
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"mp3"];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [player prepareToPlay];
        [audioPlayers setObject:player forKey:resourceName];
    }
    return player;
}

+ (id)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        audioPlayers = [[NSMutableDictionary alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (void)playSound:(NSString*)soundResourceName {
    AVAudioPlayer *player = [audioPlayers objectForKey:soundResourceName];
    if (!player) player = loadSound(soundResourceName);
    [player play];
    
}

@end
