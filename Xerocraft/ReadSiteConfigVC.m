//
//  ReadSiteConfigVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadSiteConfigVC.h"
#import "ReadQrViewController.h"
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
        ReadQrViewController* qrVC = (ReadQrViewController*) [segue destinationViewController];
        qrVC.delegate = self;
    }
}

- (void)processString:(NSString *)qrDataString {
    
    NSData *jsonData = [qrDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];

    if (!self.alreadyRead) {
        self.alreadyRead = YES;

        UIAlertView *alert = nil;
        if (err == nil && json != nil) {
            NSString *server = json[@"server"];
            NSString *site = json[@"site"];
            AppState.sharedInstance.siteName = site;
            AppState.sharedInstance.server = server;
            alert = [[UIAlertView alloc]
                initWithTitle:@"Success"
                message:[NSString stringWithFormat:@"%@/%@", site, server]
                delegate:self
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
        }
        else {
            alert = [[UIAlertView alloc]
                initWithTitle:@"Failed"
                message:qrDataString
                delegate:self
                cancelButtonTitle:@"Continue"
                otherButtonTitles:nil]; // TODO: Can a "debug" button be added which shows the err.description?
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

@end