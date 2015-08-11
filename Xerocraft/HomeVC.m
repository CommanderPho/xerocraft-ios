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

@interface HomeVC ()

@property (weak, nonatomic) IBOutlet UILabel *siteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkInOutButton;
@property (weak, nonatomic) IBOutlet UILabel *checkInOutLabel;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppState.sharedInstance addObserver:self forKeyPath:@"myCardString" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"siteName" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"checkedIn" options:NSKeyValueObservingOptionNew context:nil];
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
    BOOL checkedIn = AppState.sharedInstance.checkedIn;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.siteNameLabel.text = siteName ? siteName : @"[No Site]";
        self.serverLabel.text = server ? server : @"[No Server]";
        NSString *checkActionStr = checkedIn ? @"Check Out" : @"Check In";
        [self.checkInOutButton setTitle:checkActionStr forState:UIControlStateNormal];
        NSString *checkStatusStr = checkedIn ? @"You are checked in" : @"You are checked out";
        self.checkInOutLabel.text = checkStatusStr;
        
        [self.view setNeedsDisplay];
    });
}

- (IBAction)CheckInOutAction:(UIButton *)sender {
    
    // The new state we're trying to establish.
    // Don't set new state into AppState until the backend server responds that it noted the event.
    BOOL newState = !AppState.sharedInstance.checkedIn;
    
    // Let the backend know about the check in/out:
    VisitEventType evtType = newState ? VisitTypeArrival : VisitTypeDeparture;
    NSString* myCardStr = AppState.sharedInstance.myCardString;
    [BackendApiCommunicator.sharedInstance noteVisitEventFor:myCardStr eventType:evtType success:^(NSDictionary *json){
        AppState.sharedInstance.checkedIn = newState;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



















