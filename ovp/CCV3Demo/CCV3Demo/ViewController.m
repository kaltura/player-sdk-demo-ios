//
//  ViewController.m
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import <KALTURAPlayerSDK/KPViewController.h>
#import <KalturaPlayerSDK/GoogleCastProvider.h>

static NSString * const kViewControllerServer = @"https://cdnapisec.kaltura.com/html5/html5lib/v2.51/mwEmbedFrame.php";//

static NSString * const kViewControllerUIConfId = @"35748121";
static NSString * const kViewControllerPartnerId = @"2164401";

@interface ViewController () < GCKSessionManagerListener, GCKUIMiniMediaControlsViewControllerDelegate >

@property (weak, nonatomic) IBOutlet UILabel *messageContainer;
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (weak, nonatomic) IBOutlet UIButton *changeMediaButton;

@property (strong, nonatomic) KPViewController *playerViewController;
@property (strong, nonatomic) KPPlayerConfig *config;
@property (strong, nonatomic) NSString *currentEntryId;

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    _changeMediaButton.hidden = YES;
    
    if ([_playerViewController.view superview]) {
        [_playerViewController removePlayer];
    }
    
    appDelegate.castControlBarsEnabled = YES;
    appDelegate.miniMediaControlsViewController.delegate = self;
    [[GCKCastContext sharedInstance].sessionManager addListener: self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [[GoogleCastProvider sharedInstance] setLogo:[NSURL URLWithString: @"https://lh3.googleusercontent.com/hlVw3SIXl6Cv4zEP3Je909jHtiTjmBG-iAzfIMSgClw7cFEK6BT_UjMbzjlnmP-F_o2LtQI"]];
    [[GCKCastContext sharedInstance].sessionManager addListener: self];
    
    [self playerInitializer];
    [self switchToLocalPlayback];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [_playerViewController resetPlayer];
    
    appDelegate.castControlBarsEnabled = YES;
    appDelegate.miniMediaControlsViewController.delegate = nil;
    [[GCKCastContext sharedInstance].sessionManager removeListener: self];
}

#pragma mark - Actions

- (IBAction)changeMeida:(id)sender {
    
    [_playerViewController changeMedia: @"1_jp0fiw3x"];
}

#pragma mark - Player

- (void) playerInitializer {
    
    [self p_configWithEntryId: _currentEntryId];
    self.playerViewController = [[KPViewController alloc] initWithConfiguration: _config];
}

- (void)p_configWithEntryId:(NSString *)entryId {
    
    self.config = [[KPPlayerConfig alloc] initWithServer: kViewControllerServer
                                                uiConfID: kViewControllerUIConfId
                                               partnerId: kViewControllerPartnerId];
    _config.entryId = entryId;
    
    [_config addConfigKey:@"chromecast.plugin" withValue: @"true"];
    [_config addConfigKey:@"chromecast.useKalturaPlayer" withValue: @"true"];
    [_config addConfigKey:@"autoPlay" withValue:@"false"];
    
//    NSString *adTag = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
//    [_config addConfigKey:@"doubleClick.plugin" withValue: @"true"];
//    [_config addConfigKey:@"doubleClick.adTagUrl" withValue: adTag];
}

#pragma mark - K Player

- (void)switchToLocalPlayback {
    
    if (_playerViewController == nil) {
        
        return;
    }
    
    [self.view bringSubviewToFront: _changeMediaButton];
    [self.view bringSubviewToFront: _playerContainer];
    
    _playerViewController.view.frame = _playerContainer.bounds;
    [self addChildViewController: _playerViewController];
    [_playerContainer addSubview: _playerViewController.view];
    
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.tintColor = [UIColor grayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:castButton];
    
    typeof(self) __weak weakSelf = self;
    [_playerViewController registerReadyEvent:^{
        typeof(self) __strong strongSelf = weakSelf;
        
        if ([GCKCastContext sharedInstance].castState == GCKCastStateConnected) {
            
            [self switchToRemotePlayback];
        } else {
            
            strongSelf.changeMediaButton.hidden = NO;
        }
    }];
}

- (void)switchToRemotePlayback {

    _changeMediaButton.hidden = YES;
    _playerViewController.castProvider = [GoogleCastProvider sharedInstance];
//    [_playerViewController changeMedia: _currentEntryId];
}

#pragma mark - GCKSessionManagerListener

/**
 * Called when a Cast session has been successfully started.
 *
 * @param sessionManager The session manager.
 * @param session The Cast session.
 */

- (void)sessionManager:(GCKSessionManager *)sessionManager
       didStartSession:(GCKSession *)session {
    NSLog(@"MediaViewController: sessionManager didStartSession %@", session);
    [self switchToRemotePlayback];
}

#pragma mark - GCKUIMiniMediaControlsViewControllerDelegate

/**
 * Notifies about a change in the active state of the control bar.
 *
 * @param miniMediaControlsViewController The now playing view controller instance.
 * @param shouldAppear If <code>YES</code>, the control bar can be displayed. If <code>NO</code>,
 *     the control bar should be hidden.
 */

- (void)miniMediaControlsViewController:
(GCKUIMiniMediaControlsViewController *)miniMediaControlsViewController
                           shouldAppear:(BOOL)shouldAppear {
    
    if (shouldAppear) {
        
        _changeMediaButton.hidden = NO;
//        [self.navigationController popViewControllerAnimated: YES];
//        [appDelegate appearExpandedControlWithNavigationitem: self.navigationItem];
    }
}

#pragma mark - ViewControllerInput

- (void)shouldUpdateWithEntryId:(NSString *)entryId {
    
    self.currentEntryId = entryId;
}

@end
