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

@interface ReadSomeQrCodeVC ()

@property (nonatomic, strong) NSDictionary *memberJson;

@property (weak, nonatomic) IBOutlet UILabel *flashLabel;

@end

@implementation ReadSomeQrCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString: @"ReadQR"]) {
        ReadQrVC* qrVC = (ReadQrVC*) [segue destinationViewController];
        qrVC.delegate = self;
    }
    if ([segueName isEqualToString:@"MemberDetails"]) {
        MemberDetailsTVC* tvc = (MemberDetailsTVC*)[segue destinationViewController];
        tvc.memberJson = self.memberJson;
    }
}


typedef void(^ActionBlock)();

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
         self.memberJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
         NSString *serverError = [self.memberJson objectForKey:@"error"];
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
                 if (block) block();
             }
             if (alert) [alert show];
             
         });
     }
     ];
    [task resume];
}

- (void)flashMessage:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.flashLabel.text = msg;
        self.flashLabel.alpha = 1;
        void(^animations)(void) = ^{self.flashLabel.alpha = 0;};
        [UIView animateWithDuration:2.0
            delay:0
            options:UIViewAnimationCurveEaseOut
            animations:animations
            completion:nil];
    });
}

- (BOOL)handleMemberCardQR:(NSString*)memberCardStr {
    NSString * urlStr = [NSString stringWithFormat:@"http://%@/tasks/read-card/%@/", AppState.sharedInstance.server, memberCardStr];
    [self talkToServer:urlStr successAction:^{
        [self performSegueWithIdentifier:@"MemberDetails" sender:nil];
    }];
    return YES;
}

- (BOOL)handleLocationQR:(NSDictionary*)jsonData withLocNum:(NSInteger)locNum {
    AppState.sharedInstance.mostRecentLocation = @(locNum);
    [self flashMessage: [NSString stringWithFormat:@"Location\n#%04d\nnoted",locNum]];
    return YES;
}

- (BOOL)handlePermitQR:(NSDictionary*)jsonData withPermitNum:(NSInteger)permitNum {
    AppState *state = AppState.sharedInstance;
    NSString * urlStr = [NSString stringWithFormat:@"http://%@/inventory/note-permit-scan/%@_%@/", state.server, @(permitNum), state.mostRecentLocation];
    [self talkToServer:urlStr successAction:^{
        [self flashMessage: [NSString stringWithFormat:@"Permit %04d at\nlocation %04d\nnoted", permitNum, state.mostRecentLocation.intValue]];
    }];
    return YES;
}

- (BOOL)handleJsonData:(NSDictionary*)jsonData {
    if (jsonData) {
        
        NSString* locNumStr = [jsonData objectForKey:@"loc"];
        if (locNumStr) [self handleLocationQR:jsonData withLocNum:locNumStr.integerValue];
        
        NSString* permitNumStr = [jsonData objectForKey:@"permit"];
        if (permitNumStr) [self handlePermitQR:jsonData withPermitNum:permitNumStr.integerValue];
    }
    return YES; // I.e. DO continue scanning for QR codes, since user will be scanning batches of permits.
}

- (BOOL)qrReader:(ReadQrVC *)qrReader readString:(NSString *)qrDataString {
    
    if ([AppState isValidCardString:qrDataString]) {
        return [self handleMemberCardQR:qrDataString];
    }
    else {
        // If it's not a membership card string then it should be JSON.
        return [self handleJsonData:(NSDictionary*)qrReader.json];
    }
}

@end
