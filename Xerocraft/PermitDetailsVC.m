//
//  PermitDetailsVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 7/13/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "PermitDetailsVC.h"

@interface PermitDetailsVC ()
@property (weak, nonatomic) IBOutlet UILabel *permitNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *ownerButton;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *renewedLabel;
@property (weak, nonatomic) IBOutlet UILabel *okToMoveLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDescLabel;

@end

@implementation PermitDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    NSDictionary *p = self.permitOfInterest;

    NSString *permitNumStr = [NSString stringWithFormat:@"%04lu", (unsigned long)[p[@"permit"] integerValue]];
    NSArray *renewals = p[@"renewals"];
    NSString *renewedStr = @"None";
    if (renewals && renewals.count>0) renewedStr = renewals.lastObject;
    NSString *okToMoveStr = ((NSNumber*)p[@"ok_to_move"]).boolValue ? @"Yes" : @"No";

    //TODO: self.permitOwner = p[@"owner_pk"] and associated segue from self.ownerButton
    
    [self.ownerButton setTitle:p[@"owner_name"] forState:UIControlStateNormal];
    self.permitNumLabel.text = permitNumStr;
    self.createdLabel.text = p[@"created"];
    self.renewedLabel.text = renewedStr;
    self.okToMoveLabel.text = okToMoveStr;
    self.shortDescLabel.text = p[@"short_desc"];
    
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
