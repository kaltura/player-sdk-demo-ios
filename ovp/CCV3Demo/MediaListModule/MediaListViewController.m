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

static CGFloat const kMediaListViewControllerAnimationDuration = 1.0;
static NSString * const kMediaListViewControllerKeyEntryId = @"entryid";

@interface MediaListViewController () <GCKUIMiniMediaControlsViewControllerDelegate>

@property (nonatomic, copy) NSString *currentEntryId;
@property (nonatomic, strong) GCKUIMiniMediaControlsViewController *miniMediaControlsViewController;
@property (weak, nonatomic) IBOutlet UIView *miniMediaControlsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *miniMediaControlsHeightConstraint;

@property (strong, nonatomic) ViewController *playerViewController;

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
    
    GCKCastContext *castContext = [GCKCastContext sharedInstance];
    _miniMediaControlsViewController = [castContext createMiniMediaControlsViewController];
    _miniMediaControlsViewController.delegate = self;
    
    [self addChildViewController:_miniMediaControlsViewController];
    _miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds;
    [_miniMediaControlsContainerView addSubview:_miniMediaControlsViewController.view];
    [_miniMediaControlsViewController didMoveToParentViewController:self];
    
    [self updateControlBarsVisibility];
    
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:castButton];
}

- (void)updateControlBarsVisibility {
    
    if (_miniMediaControlsViewController.active) {
        
        _miniMediaControlsHeightConstraint.constant = _miniMediaControlsViewController.minHeight;
    } else {
        
        _miniMediaControlsHeightConstraint.constant = 0;
    }
    
    [UIView animateWithDuration:kMediaListViewControllerAnimationDuration animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

- (void)miniMediaControlsViewController:(GCKUIMiniMediaControlsViewController *) miniMediaControlsViewController shouldAppear:(BOOL)shouldAppear {
    [self updateControlBarsVisibility];
}

- (void)playSelectedItemRemotely {
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[GCKCastContext sharedInstance] presentDefaultExpandedMediaControls];
}

#pragma mark - MediaListDataDisplayManagerDelegate

- (void) didUpdateForDataDisplayManager: (MediaListDataDisplayManager *)ddManager {
    
    [_tableView reloadData];
}

- (void) dataDisplayManager: (MediaListDataDisplayManager *)ddManager didSelectPlainObj:(MediaPlainObject *)plain {
    
    self.currentEntryId = plain.name;
    NSString *entryIdForCurrentCastMedia = [[[[[[[[GCKCastContext sharedInstance] sessionManager] currentSession] remoteMediaClient] mediaStatus] mediaInformation] metadata] objectForKey: kMediaListViewControllerKeyEntryId];
    
    if (entryIdForCurrentCastMedia.length > 0 && [plain.name isEqualToString: entryIdForCurrentCastMedia] && _miniMediaControlsViewController.active) {
        
        [self playSelectedItemRemotely];
    } else {
        
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
