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
#import <GoogleCast/GoogleCast.h>
#import <KalturaPlayerSDK/GoogleCastProvider.h>

static NSString * const kViewControllerServer = @"http://cdnapi.kaltura.com";

static NSString * const kViewControllerUIConfId = @"37484452";
static NSString * const kViewControllerPartnerId = @"2212491";

@interface ViewController () <GCKSessionManagerListener>

@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *changeMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) KPViewController *playerViewController;
@property (strong, nonatomic) KPPlayerConfig *config;
@property (strong, nonatomic) GoogleCastProvider *castProvider;
@property (strong, nonatomic) NSString *currentEntryId;

@end

@implementation ViewController

#pragma mark - Life cycle

- (IBAction)backDidClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController.navigationBar setHidden: YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    if ([_playerViewController.view superview]) {
        [_playerViewController removePlayer];
    }

    [self p_configWithEntryId: _currentEntryId];
    self.castProvider = [GoogleCastProvider sharedInstance];
    [_castProvider setLogo:[NSURL URLWithString: @"https://lh3.googleusercontent.com/hlVw3SIXl6Cv4zEP3Je909jHtiTjmBG-iAzfIMSgClw7cFEK6BT_UjMbzjlnmP-F_o2LtQI"]];
    
    self.playerViewController = [[KPViewController alloc] initWithConfiguration: _config];
    
    [_playerViewController loadPlayerIntoViewController: self];
    [self addChildViewController: _playerViewController];
    [self.view addSubview: _playerViewController.view];
    
    _playerViewController.view.frame = self.view.frame;
    
    [self.view bringSubviewToFront: _castButton];
    [self.view bringSubviewToFront: _changeMediaButton];
    [self.view bringSubviewToFront: _backButton];
    
    [[GCKCastContext sharedInstance].sessionManager addListener: self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [_playerViewController resetPlayer];
}

#pragma mark - Actions

- (IBAction)didClickCastButton:(id)sender {
    
    self.castProvider = [GoogleCastProvider sharedInstance];
    _playerViewController.castProvider = _castProvider;
    
    GCKRemoteMediaClient *remoteMediaClient = [GCKCastContext sharedInstance].sessionManager.currentSession.remoteMediaClient;
    if (remoteMediaClient.mediaStatus) {
    
        [_playerViewController changeMedia: _currentEntryId];
    }
}

- (IBAction)changeMeida:(id)sender {
    
    [_playerViewController changeMedia: @"0_63rji9fo"];
}

#pragma mark - ViewControllerInput

- (void)shouldUpdateWithEntryId:(NSString *)entryId {
    
    self.currentEntryId = entryId;
}

#pragma mark - Player

- (void)p_configWithEntryId:(NSString *)entryId {
    
    self.config = [[KPPlayerConfig alloc] initWithServer: kViewControllerServer
                                                uiConfID: kViewControllerUIConfId
                                               partnerId: kViewControllerPartnerId];
    _config.entryId = entryId;
    
    [_config addConfigKey:@"chromecast.plugin" withValue: @"true"];
    [_config addConfigKey:@"chromecast.useKalturaPlayer" withValue: @"true"];
    [_config addConfigKey:@"autoPlay" withValue:@"true"];
    
//    NSString *adTag = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
//    [_config addConfigKey:@"doubleClick.plugin" withValue: @"true"];
//    [_config addConfigKey:@"doubleClick.adTagUrl" withValue: adTag];
}

@end
