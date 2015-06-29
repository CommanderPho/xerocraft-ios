//
//  ReadOthersCardVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadSomeQrCodeVC.h"
#import "ReadQrViewController.h"
#import "AppState.h"

@interface ReadSomeQrCodeVC ()

@property (nonatomic, assign) NSString *lastScanned;

@end

@implementation ReadSomeQrCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastScanned = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"ReadQR"]) {
        ReadQrViewController* qrVC = (ReadQrViewController*) [segue destinationViewController];
        qrVC.delegate = self;
    }
}

- (BOOL)processString:(NSString *)qrDataString {

    // Ignore duplicate scans.
    if ([qrDataString isEqualToString:self.lastScanned]) return YES;
        
    if ([AppState isValidCardString:qrDataString]) {
        //TODO: Get info from server then seque to table view of member.
        return NO; // I.e. do not continue scanning for QR codes.
    }

    // If it's not a membership card string then it should be JSON.
    NSData *jsonData = [qrDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    
    if (!err && !json) {
        NSString *permitNumber = json[@"permit"];
        if (permitNumber != nil) {
            //TODO: Log the permit read.  Flash "SCANNED!" message and beep.
            return YES; // I.e. DO continue scanning for QR codes, since user will be scanning batches of permits.
        }
    }
    
    // Code isn't json or is a sort of json that's not appropriate for this app or this scene.
    return YES;
}

@end
