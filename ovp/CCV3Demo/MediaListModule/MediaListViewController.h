//
//  ViewController.m
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaListDataDisplayManager.h"

@interface MediaListViewController : UIViewController <MediaListDataDisplayManagerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MediaListDataDisplayManager *dataDisplayManager;
@property (nonatomic, strong) NSArray *mediaList;

@end
