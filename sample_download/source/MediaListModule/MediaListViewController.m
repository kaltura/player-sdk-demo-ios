//
//  MediaListViewController.m
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "MediaListViewController.h"
#import "PlayerViewController.h"

@interface MediaListViewController () 

@property (nonatomic, strong) MediaPlainObject *currentPlain;

@end

@implementation MediaListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController.navigationBar setHidden: NO];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Media List";
    
    _tableView.delegate = _dataDisplayManager;
    _tableView.dataSource = _dataDisplayManager;
    
    [_dataDisplayManager updateTableViewModelWithPlainObjects: _mediaList];
}

#pragma mark - MediaListDataDisplayManagerDelegate

- (void) didUpdateForDataDisplayManager: (MediaListDataDisplayManager *)ddManager {
    
    [_tableView reloadData];
}

- (void) dataDisplayManager: (MediaListDataDisplayManager *)ddManager 
          didSelectPlainObj: (MediaPlainObject *)plain {
    
    self.currentPlain = plain;
    [self performSegueWithIdentifier: kShowDetailPlayerViewController sender: nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender {
    
    if ([segue.identifier isEqualToString: kShowDetailPlayerViewController]) {
    
        UIViewController *destination = segue.destinationViewController;
        BOOL validateParams = [destination isKindOfClass: [PlayerViewController class]] && _currentPlain;
        if (validateParams) {
            
            PlayerViewController *viewController = (PlayerViewController *)destination;
            [viewController shouldUpdateCurrentModuleWithMediaPlainObject: _currentPlain];
        }
    }
}

@end
