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

- (void)processString:(NSString *)qrDataString {
    
    // TODO: VAlidate qrDataString. Should be 32 chars of url-save base64. [-_a-zA-Z0-9]{32}
    
    if (!self.alreadyRead) {
        self.alreadyRead = YES;
        
        AppState.sharedInstance.myCardString = qrDataString;
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Success"
            message:@"[Card String Hidden]"
            delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

@end
