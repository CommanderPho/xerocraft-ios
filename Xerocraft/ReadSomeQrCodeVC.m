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
#import "BackendApiCommunicator.h"

@interface ReadSomeQrCodeVC ()

@property (nonatomic, strong) NSDictionary *memberJson;
@property (nonatomic, strong) NSDictionary *permitJson;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *permitButton;

@property (strong, nonatomic, readonly) BackendApiCommunicator* xeroAPI;

@end

@implementation ReadSomeQrCodeVC

- (void)viewDidLoad {
    _memberJson = nil;
    _permitJson = nil;
    _xeroAPI = BackendApiCommunicator.sharedInstance;
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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pragma mark QR Handlers

- (BOOL)handleMemberCardQR:(NSString*)memberCardStr {
    NSString *myCardStr = AppState.sharedInstance.myCardString;
    [self.xeroAPI getMemberDetailsForStr:memberCardStr onBehalfOf:myCardStr
        success:^(NSDictionary *json) {
            self.memberJson = json;
            [self performSegueWithIdentifier:@"MemberDetails" sender:nil];
        }
        failure:nil
    ];
    return YES;
}

- (BOOL)handleLocationQR:(NSInteger)locNum {
    if (AppState.sharedInstance.mostRecentLocation != nil) {
        [self donePermitsForLocation];
    }
    AppState.sharedInstance.mostRecentLocation = @(locNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        long loc = AppState.sharedInstance.mostRecentLocation.integerValue;
        [self.locationButton setTitle:[NSString stringWithFormat:@"L%04ld",loc] forState:UIControlStateNormal];
        self.locationButton.hidden = NO;
    });
    return YES;
}

- (BOOL)handlePermitQR:(NSDictionary*)jsonData withPermitNum:(NSUInteger)permitNum {

    NSNumber *mostRecentLoc = AppState.sharedInstance.mostRecentLocation;
    
    [self.xeroAPI getPermitDetailsForNum:permitNum
        success:^(NSDictionary *json){
        
            self.permitJson = json;

            if (AppState.sharedInstance.mostRecentLocation != nil) {
                // The user is taking inventory

                //TODO: Was permit was most recently scanned at a different location.  If so, ask "did you forget to scan a location QR?"
                
                // Inform backend server:
                [self.xeroAPI notePermitScanOf:permitNum atLocation:mostRecentLoc.unsignedLongValue success:nil failure:nil];
                
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
        }
        failure:nil
    ];
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
