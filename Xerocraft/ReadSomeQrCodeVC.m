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

@interface ReadSomeQrCodeVC ()

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
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"ReadQR"]) {
        ReadQrVC* qrVC = (ReadQrVC*) [segue destinationViewController];
        qrVC.delegate = self;
    }
}

- (BOOL)qrReader:(ReadQrVC *)qrReader readString:(NSString *)qrDataString {
    
    if ([AppState isValidCardString:qrDataString]) {
        //TODO: Get info from server then seque to table view of member.
        return NO; // I.e. do not continue scanning for QR codes.
    }

    // If it's not a membership card string then it should be JSON.
    NSObject *json = qrReader.json;
    
    if (json) {
        NSString *permitNumber = [json valueForKey:@"permit"];
        if (permitNumber != nil) {
            //TODO: Log the permit read.  Flash "SCANNED!" message and beep.
            return YES; // I.e. DO continue scanning for QR codes, since user will be scanning batches of permits.
        }
    }
    
    // Code isn't json or is a sort of json that's not appropriate for this app or this scene.
    return YES;
}

@end
