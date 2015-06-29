//
//  ConfigurationVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/28/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ConfigurationVC.h"
#import "AppState.h"

@interface ConfigurationVC ()
@property (weak, nonatomic) IBOutlet UIImageView *myCardStatusImg;
@property (weak, nonatomic) IBOutlet UIImageView *SiteStatusImg;

@end

@implementation ConfigurationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    [AppState.sharedInstance addObserver:self forKeyPath:@"myCardString" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"siteName" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)updateProblemBadges {
    // NOTE: Problem "badges" are actually images.
    BOOL haveMyCard = AppState.sharedInstance.myCardString != nil;
    BOOL haveSiteName = AppState.sharedInstance.siteName != nil;
    BOOL haveServer = AppState.sharedInstance.server != nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage* check = [UIImage imageNamed:@"Green Check"];
        UIImage* ex = [UIImage imageNamed:@"Red X"];
        self.myCardStatusImg.image = haveMyCard ? check : ex;
        self.SiteStatusImg.image = haveSiteName && haveServer ? check : ex;
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateProblemBadges];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == nil) [self updateProblemBadges];
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
