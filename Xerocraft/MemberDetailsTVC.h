//
//  MemberDetailsTVC.h
//  Xerocraft
//
//  Created by Adrian Boyko on 6/30/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberDetailsTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *memberJson;

@end
