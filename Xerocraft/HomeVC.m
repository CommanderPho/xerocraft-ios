//
//  HomeVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 6/25/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "HomeVC.h"
#import "AppState.h"

@interface HomeVC ()
@property (weak, nonatomic) IBOutlet UILabel *siteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCardStrLabel1;
@property (weak, nonatomic) IBOutlet UILabel *myCardStrLabel2;
@property (weak, nonatomic) IBOutlet UILabel *myCardStrLabel3;
@property (weak, nonatomic) IBOutlet UILabel *myCardStrLabel4;


@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppState.sharedInstance addObserver:self forKeyPath:@"myCardString" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"server" options:NSKeyValueObservingOptionNew context:nil];
    [AppState.sharedInstance addObserver:self forKeyPath:@"siteName" options:NSKeyValueObservingOptionNew context:nil];
    [self updateLabels];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == nil) [self updateLabels];
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (void)updateLabels {
    
    NSString *siteName = AppState.sharedInstance.siteName;
    NSString *server = AppState.sharedInstance.server;
    NSString *myCardString = AppState.sharedInstance.myCardString;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.siteNameLabel.text = siteName ? siteName : @"[No Site]";
        self.serverLabel.text = server ? server : @"[No Server]";
        
        if (myCardString == nil) {
            self.myCardStrLabel1.text = @"[No Card String]";
            self.myCardStrLabel2.text = @"-";
            self.myCardStrLabel3.text = @"-";
            self.myCardStrLabel4.text = @"-";
        }
        else {
            self.myCardStrLabel1.text = [myCardString substringWithRange:NSMakeRange(0, 8)];
            self.myCardStrLabel2.text = [myCardString substringWithRange:NSMakeRange(8, 8)];;
            self.myCardStrLabel3.text = [myCardString substringWithRange:NSMakeRange(16, 8)];;
            self.myCardStrLabel4.text = [myCardString substringWithRange:NSMakeRange(24, 8)];;
        }
        [self.view setNeedsDisplay];
    });
}

- (IBAction)resetButtonAction:(UIButton *)sender {
    AppState.sharedInstance.siteName = nil;
    AppState.sharedInstance.server = nil;
    AppState.sharedInstance.myCardString = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
