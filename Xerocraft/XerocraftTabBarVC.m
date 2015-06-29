//
//  XerocraftTabBarVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/26/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "XerocraftTabBarVC.h"
#import "AppState.h"

@interface XerocraftTabBarVC ()

@end

@implementation XerocraftTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppState.sharedInstance addObserver:self forKeyPath:@"myCardString" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"siteName" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateProblemBadge];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == nil) [self updateProblemBadge];
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)updateProblemBadge {
    
    int problemCount = 0;
    if (AppState.sharedInstance.siteName == nil || AppState.sharedInstance.server == nil) problemCount++;
    if (AppState.sharedInstance.myCardString == nil) problemCount++;
    NSString *problemStr = [NSString stringWithFormat:@"%d", problemCount];
    if (problemCount == 0) problemStr = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBar.items[2] setBadgeValue:problemStr];
        [self.tabBar setNeedsDisplay];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
