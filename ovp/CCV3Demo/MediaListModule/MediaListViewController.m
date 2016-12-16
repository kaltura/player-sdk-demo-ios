//
//  ViewController.m
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "MediaListViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewInput.h"

#import <GoogleCast/GoogleCast.h>

@interface MediaListViewController ()

@property (nonatomic, copy) NSString *currentEntryId;
@property (strong, nonatomic) ViewController *playerViewController;

@end

@implementation MediaListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController.navigationBar setHidden: NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
     [[GCKCastContext sharedInstance] presentCastInstructionsViewControllerOnce];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Media List";
    
    _tableView.delegate = _dataDisplayManager;
    _tableView.dataSource = _dataDisplayManager;
    
    [_dataDisplayManager updateTableViewModelWithPlainObjects: _mediaList];
    
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:castButton];
}

#pragma mark - MediaListDataDisplayManagerDelegate

- (void)didUpdateForDataDisplayManager: (MediaListDataDisplayManager *)ddManager {
    
    [_tableView reloadData];
}

- (void)dataDisplayManager: (MediaListDataDisplayManager *)ddManager didSelectPlainObj:(MediaPlainObject *)plain {
    
    if ([appDelegate shouldAppearExpandedControlWithCurrentEntryId: plain.name]) {
        
        [appDelegate appearExpandedControlWithNavigationitem: self.navigationItem];
    } else {
        
        self.currentEntryId = plain.name;
        
        if (!_playerViewController) {
            
            self.playerViewController = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"PlayerViewController"];
        }
        
        if ([_playerViewController conformsToProtocol:@protocol(ViewInput)]) {
            
            id<ViewInput> viewInput = (id<ViewInput>)_playerViewController;
            [viewInput shouldUpdateWithEntryId: _currentEntryId];
        }
        
        [self.navigationController pushViewController: _playerViewController animated: YES];
    }
}

@end
