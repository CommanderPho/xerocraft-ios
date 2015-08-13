//
//  HomeVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/25/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "HomeVC.h"
#import "AppState.h"
#import "BackendApiCommunicator.h"
#import "SoundManager.h"

@interface HomeVC ()

@property (weak, nonatomic) IBOutlet UILabel *siteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;

@property (strong, nonatomic) UIColor *origInOutBG;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.origInOutBG = self.checkInButton.backgroundColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppState.sharedInstance addObserver:self forKeyPath:@"myCardString" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"siteName" options:NSKeyValueObservingOptionNew context:nil];
    [self updateLabels];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == nil) [self updateLabels];
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)updateLabels {
    
    NSString *siteName = AppState.sharedInstance.siteName;
    NSString *server = AppState.sharedInstance.server;
    //NSString *myCardString = AppState.sharedInstance.myCardString;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.siteNameLabel.text = siteName ? siteName : @"[No Site]";
        self.serverLabel.text = server ? server : @"[No Server]";
        [self.view setNeedsDisplay];
    });
}

- (IBAction)CheckInOutAction:(UIButton *)sender {
    
    // Don't let user push check IN or OUT while this request is being processed.
    sender.enabled = NO;
    UIColor *successBG = [UIColor colorWithRed:204.0/255.0 green:235.0/255.0 blue:197.0/255.0 alpha:1.0];
    
    // Let the backend know about the check in/out:
    BOOL isCheckIn = sender == self.checkInButton;
    VisitEventType evtType = isCheckIn ? VisitTypeArrival : VisitTypeDeparture;
    NSString *myCardStr = AppState.sharedInstance.myCardString;
    [BackendApiCommunicator.sharedInstance noteVisitEventFor:myCardStr eventType:evtType
        success:^(NSDictionary *json) {
            [SoundManager.sharedInstance playSound:@"beep23"];
            if (isCheckIn) AppState.sharedInstance.mostRecentBackendCheckIn = [NSDate date];
            else AppState.sharedInstance.mostRecentBackendCheckOut = [NSDate date];
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.enabled = YES;
                sender.backgroundColor = successBG;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                NSUInteger opts = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut ;
                [UIView animateWithDuration:1.0 delay:0.0 options:opts animations:^{sender.backgroundColor=self.origInOutBG; } completion:nil];
            });
        }
        failure:^(NSDictionary *json) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
        }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

















