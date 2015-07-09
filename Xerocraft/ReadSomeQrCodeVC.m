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
    // 192.168.1.101:8000/tasks/read-card/eNrBIc1XRSG9xDuNA1as5iF5c5ufZkTe
- (BOOL)handleMemberCardQR:(NSString*)memberCardStr {
    NSString * urlStr = [NSString stringWithFormat:@"http://%@/read-card/%@/", AppState.sharedInstance.server, memberCardStr];
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
                            [self performSegueWithIdentifier:@"MemberDetails" sender:nil];
                        }
                        if (alert) [alert show];
                        
                    });
                }
        ];
    [task resume];
    return YES; //REVIEW: Maybe different results for different errors and success.
}

- (BOOL)handleJsonData:(NSDictionary*)jsonData {
    if (jsonData) {
        NSString *permitNumber = [jsonData valueForKey:@"permit"];
        if (permitNumber != nil) {
            //TODO: Log the permit read.  Flash "SCANNED!" message and beep.
        }
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
