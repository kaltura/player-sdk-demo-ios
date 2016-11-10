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
static NSString * const kViewControllerUIConfId = @"37150601";
static NSString * const kViewControllerPartnerId = @"2212491";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *changeMediaButton;
@property (strong, nonatomic) NSString *currentEntryId;
@property (strong, nonatomic) KPViewController *playerViewController;
@property (strong, nonatomic) GoogleCastProvider *castProvider;
@end

@implementation ViewController

#pragma mark - Life cycle

- (void)dealloc {
    
    [_playerViewController removePlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithServer: kViewControllerServer
                                                           uiConfID: kViewControllerUIConfId
                                                          partnerId: kViewControllerPartnerId];
    config.entryId = _currentEntryId;
    
    [config addConfigKey:@"chromecast.plugin" withValue: @"true"];
    [config addConfigKey:@"chromecast.useKalturaPlayer" withValue: @"true"];
    
    self.castProvider = [GoogleCastProvider sharedInstance];
    
    [_castProvider setLogo:[NSURL URLWithString: @"https://lh3.googleusercontent.com/hlVw3SIXl6Cv4zEP3Je909jHtiTjmBG-iAzfIMSgClw7cFEK6BT_UjMbzjlnmP-F_o2LtQI"]];
    
    self.playerViewController = [[KPViewController alloc] initWithConfiguration: config];
    _playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_playerViewController loadPlayerIntoViewController: self];
    [self addChildViewController: _playerViewController];
    [self.view addSubview: _playerViewController.view];
    
    [self.view bringSubviewToFront: _castButton];
    [self.view bringSubviewToFront: _changeMediaButton];
    
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:castButton];
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
    
    [_playerViewController changeMedia: _currentEntryId];
}

#pragma mark - ViewControllerInput

- (void)shouldUpdateWithEntryId:(NSString *)entryId {
    
    self.currentEntryId = entryId;
}

@end
