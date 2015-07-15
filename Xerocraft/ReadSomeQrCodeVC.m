//
//  ReadOthersCardVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadSomeQrCodeVC.h"
#import "ReadQrVC.h"
#import "AppState.h"
#import "MemberDetailsTVC.h"
#import "PermitDetailsVC.h"

@interface ReadSomeQrCodeVC ()

@property (nonatomic, strong) NSDictionary *memberJson;
@property (nonatomic, strong) NSDictionary *permitJson;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *permitButton;


@end

@implementation ReadSomeQrCodeVC

- (void)viewDidLoad {
    _memberJson = nil;
    _permitJson = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.permitButton.alpha = 0;
    NSNumber *locObj = AppState.sharedInstance.mostRecentLocation;
    if (locObj != nil) [self handleLocationQR:locObj.integerValue];
    else self.locationButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // There might be a permit button animation in progress, so short it.
    [self.permitButton.layer removeAllAnimations];
    self.permitButton.alpha = 0.0;
    
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString: @"ReadQR"]) {
        ReadQrVC* qrVC = (ReadQrVC*)[segue destinationViewController];
        qrVC.delegate = self;
    }
    if ([segueName isEqualToString:@"MemberDetails"]) {
        MemberDetailsTVC* mdVC = (MemberDetailsTVC*)[segue destinationViewController];
        mdVC.memberJson = self.memberJson;
    }
    if ([segueName isEqualToString: @"PermitDetails"]) {
        PermitDetailsVC* permVC = (PermitDetailsVC*)[segue destinationViewController];
        permVC.permitOfInterest = self.permitJson;
    }
}

#pragma mark Server Communication

typedef void(^ActionBlock)(NSDictionary*);

- (void) talkToServer:(NSString*)urlStr successAction:(ActionBlock)block{
    
    //TODO: This doesn't deal with 404, etc.
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSession *session = [NSURLSession sharedSession];
    session.configuration.timeoutIntervalForRequest = 2;
    NSURLSessionDataTask *task =
    [session
     dataTaskWithURL:url
     completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *connectError){
         NSError* parseError = nil;
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
         NSString *serverError = [json objectForKey:@"error"];
         dispatch_async(dispatch_get_main_queue(),^{
             UIAlertView *alert = nil;
             if (connectError) {
                 alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't connect to server." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
             }
             else if (parseError) {
                 alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't parse response." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
             }
             else if (serverError) {
                 alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:serverError delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
             }
             else {
                 assert(alert == nil);
                 if (block) block(json);
             }
             if (alert) [alert show];
             
         });
     }
     ];
    [task resume];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pragma mark QR Handlers

- (BOOL)handleMemberCardQR:(NSString*)memberCardStr {
    NSString * urlStr = [NSString stringWithFormat:@"http://%@/tasks/read-card/%@/", AppState.sharedInstance.server, memberCardStr];
    [self talkToServer:urlStr successAction:^(NSDictionary *json) {
        self.memberJson = json;
        [self performSegueWithIdentifier:@"MemberDetails" sender:nil];
    }];
    return YES;
}

- (BOOL)handleLocationQR:(NSInteger)locNum {
    if (AppState.sharedInstance.mostRecentLocation != nil) {
        [self donePermitsForLocation];
    }
    AppState.sharedInstance.mostRecentLocation = @(locNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        int loc = AppState.sharedInstance.mostRecentLocation.integerValue;
        [self.locationButton setTitle:[NSString stringWithFormat:@"L%04d",loc] forState:UIControlStateNormal];
        self.locationButton.hidden = NO;
    });
    return YES;
}


- (BOOL)handlePermitQR:(NSDictionary*)jsonData withPermitNum:(NSUInteger)permitNum {

    NSString *server = AppState.sharedInstance.server;
    NSNumber *mostRecentLoc = AppState.sharedInstance.mostRecentLocation;
    
    NSString *urlStr1 = [NSString stringWithFormat:@"http://%@/inventory/get-permit-details/%@/", server, @(permitNum)];
    [self talkToServer:urlStr1 successAction:^(NSDictionary *json){
        
        self.permitJson = json;

        if (AppState.sharedInstance.mostRecentLocation != nil) {
            // The user is taking inventory

            //TODO: Was permit was most recently scanned at a different location.  If so, ask "did you forget to scan a location QR?"
            
            // Inform backend server:
            NSString *urlStr2 = [NSString stringWithFormat:@"http://%@/inventory/note-permit-scan/%@_%@/", server, @(permitNum), mostRecentLoc];
            [self talkToServer:urlStr2 successAction:nil];
            
            // Show the permit number in the GUI, for a few seconds:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.permitButton setTitle:[NSString stringWithFormat:@"P%04lu", (unsigned long)permitNum] forState:UIControlStateNormal];
                self.permitButton.alpha = 1;
                // Jumping through some hoops with animation to enable user interaction. Final value for alpha ramp cannot be 0.0.
                NSUInteger opts = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut ;
                [UIView animateWithDuration:1.0 delay:3.0 options:opts animations:^{self.permitButton.alpha=0.05;} completion:^(BOOL x){self.permitButton.alpha=0.0;}];
            });
        }
        else {
            // The user wants permit details.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"PermitDetails" sender:self];
            });
        }
    }];
    return YES;
}

- (BOOL)qrReader:(ReadQrVC *)qrReader readString:(NSString *)qrDataString {
    
    if ([AppState isValidCardString:qrDataString]) {
        return [self handleMemberCardQR:qrDataString];
    }
    else {
        NSDictionary *json = (NSDictionary*)qrReader.json;
        NSString* locNumStr = [json objectForKey:@"loc"];
        if (locNumStr) return [self handleLocationQR:locNumStr.integerValue];
        
        NSString* permitNumStr = [json objectForKey:@"permit"];
        if (permitNumStr) return [self handlePermitQR:json withPermitNum:permitNumStr.integerValue];
    }
    return YES;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pragma mark Location Start/End

- (void)startPermitsForLocation {
    // TODO: Initialize batch compare.
}

- (void)donePermitsForLocation {
    NSUInteger locNum = AppState.sharedInstance.mostRecentLocation.unsignedIntegerValue;
    AppState.sharedInstance.mostRecentLocation = nil;
    //TODO: Do batch compare and set vanished permits to unknown location.
}

- (IBAction)LocationTouchUp:(UIButton *)sender {
    self.locationButton.hidden = YES;
    [self donePermitsForLocation];
}

@end
