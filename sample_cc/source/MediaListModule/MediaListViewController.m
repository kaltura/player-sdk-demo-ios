//
//  MediaListViewController.m
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "MediaListViewController.h"
#import "CCViewController.h"

@interface MediaListViewController () 

@property (nonatomic, copy) NSString *currentEntryId;

@end

@implementation MediaListViewController

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

- (void) dataDisplayManager: (MediaListDataDisplayManager *)ddManager didSelectPlainObj:(MediaPlainObject *)plain {
    
    self.currentEntryId = plain.name;
    [self performSegueWithIdentifier: kShowCCViewController sender: nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: kShowCCViewController]) {
        
        UIViewController *destination = segue.destinationViewController;
        if ([destination isKindOfClass: [CCViewController class]]) {
            
            CCViewController *viewController = (CCViewController *)destination;
            [viewController shouldUpdateWithEntryId: _currentEntryId];
        }
    }
}

@end
