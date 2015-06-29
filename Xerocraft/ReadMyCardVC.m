//
//  ReadMyCardVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadMyCardVC.h"
#import "ReadQrViewController.h"
#import "AppState.h"

@interface ReadMyCardVC ()
@property (weak, nonatomic) IBOutlet UIView *qrReader;
@property (nonatomic, assign) BOOL alreadyRead;

@end

@implementation ReadMyCardVC

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
        ReadQrViewController* qrVC = (ReadQrViewController *) [segue destinationViewController];
        qrVC.delegate = self;
    }
}

- (BOOL)processString:(NSString *)qrDataString {
    
    if (!self.alreadyRead) {
        self.alreadyRead = YES;
        
        UIAlertView* alert = nil;
        
        if ([AppState isValidCardString:qrDataString]) {
            AppState.sharedInstance.myCardString = qrDataString;
        }
        else {
            alert = [[UIAlertView alloc]
                initWithTitle:@"Error"
                message:@"The code you scanned doesn't appear to be a membership card code."
                delegate:self
                cancelButtonTitle:@"Continue"
                otherButtonTitles:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (alert) [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    return NO; // I.e. do not continue scanning for QR codes.
}

@end
