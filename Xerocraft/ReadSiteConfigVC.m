//
//  ReadSiteConfigVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadSiteConfigVC.h"
#import "ReadQrVC.h"
#import "AppState.h"

@interface ReadSiteConfigVC ()

@property (nonatomic, assign) BOOL alreadyRead;

@end

@implementation ReadSiteConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _alreadyRead = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"ReadQR"]) {
        ReadQrVC* qrVC = (ReadQrVC*) [segue destinationViewController];
        qrVC.delegate = self;
    }
}

- (BOOL)qrReader:(ReadQrVC *)qrReader readString:(NSString *)qrDataString {
    

    if (!self.alreadyRead) {
        self.alreadyRead = YES;

        UIAlertView *alert = nil;
        NSString *server = nil;
        NSString *site = nil;

        NSObject *json = qrReader.json;
        if (json) {
            server = [json valueForKey:@"server"];
            site = [json valueForKey:@"site"];
        }
        if (server && site) {
            AppState.sharedInstance.siteName = site;
            AppState.sharedInstance.server = server;
        }
        else {
            alert = [[UIAlertView alloc]
                initWithTitle:@"Error"
                message:@"The code you've scanned doesn't appear to be a valid site configuration code."
                delegate:self
                cancelButtonTitle:@"Continue"
                otherButtonTitles:nil]; // TODO: Can a "debug" button be added which shows the err.description?
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (alert) [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    return NO; // I.e. do not continue scanning for QR codes.
}

@end
