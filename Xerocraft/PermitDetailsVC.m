//
//  PermitDetailsVC.m
//  Xerocraft
//
//  Created by Adrian Boyko on 7/13/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import "PermitDetailsVC.h"

@interface PermitDetailsVC ()

@property (nonatomic, strong) NSString *ownerDetail;
@property (nonatomic, strong) NSString *createdDetail;
@property (nonatomic, strong) NSString *renewedDetail;
@property (nonatomic, strong) NSString *okToMoveDetail;

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

    NSString *permitNumStr = [NSString stringWithFormat:@"Permit %04lu", (unsigned long)[p[@"permit"] integerValue]];
    NSArray *renewals = p[@"renewals"];
    NSString *renewedStr = @"Never";
    if (renewals && renewals.count>0) renewedStr = renewals.lastObject;
    NSString *okToMoveStr = ((NSNumber*)p[@"ok_to_move"]).boolValue ? @"Yes" : @"No";

    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = permitNumStr;
    self.shortDescLabel.text = p[@"short_desc"];

    self.ownerDetail = p[@"owner_name"];
    self.createdDetail = p[@"created"];
    self.renewedDetail = renewedStr;
    self.okToMoveDetail = okToMoveStr;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PermitCell"];
    switch(indexPath.row) {
        case 0:
            cell.detailTextLabel.text = self.ownerDetail;
            cell.textLabel.text = @"Owner";
            break;

        case 1:
            cell.detailTextLabel.text = self.createdDetail;
            cell.textLabel.text = @"Created";
            break;

        case 2:
            cell.detailTextLabel.text = self.renewedDetail;
            cell.textLabel.text = @"Renewed";
            break;

        case 3:
            cell.detailTextLabel.text = self.okToMoveDetail;
            cell.textLabel.text = @"OK to Move";
            break;
    }
    return cell;
}

@end
