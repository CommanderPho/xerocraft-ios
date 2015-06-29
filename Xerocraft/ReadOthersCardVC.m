//
//  ReadOthersCardVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/23/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "ReadOthersCardVC.h"
#import "ReadQrViewController.h"

@interface ReadOthersCardVC ()

@end

@implementation ReadOthersCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    NSLog(@"%@",qrDataString);
}

@end
