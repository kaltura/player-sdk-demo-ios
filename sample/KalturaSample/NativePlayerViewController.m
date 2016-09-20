//
//  ThirdViewController.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/6/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "NativePlayerViewController.h"
#import "KalturaPlayerViewController.h"

#import "AppDelegate.h"

static NSString * const kSecondUIConfigurationViewControllerUIConfId = @"35750171";
static NSString * const kSecondUIConfigurationViewControllerPartnerId = @"2164401";
static NSString * const kSecondUIConfigurationViewControllerEntryId = @"1_jp0fiw3x";
//static NSString * const kSecondUIConfigurationViewControllerUIConfId = @"32855491";
//static NSString * const kSecondUIConfigurationViewControllerPartnerId = @"1424501";
//static NSString * const kSecondUIConfigurationViewControllerEntryId = @"1_ypo9wae3";

@interface NativePlayerViewController () <KalturaPlayerViewControllerDelegate>

@property (nonatomic, strong) KalturaPlayerViewController *kalturaPlayerViewController;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (nonatomic, strong) PrepareConfigBlock prepareConfBlock;

@end

@implementation NativePlayerViewController

#pragma mark - Life cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self p_playerModerator];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self p_removePlayerFromSuperView];
}

#pragma mark - Private methods

- (void) p_playerModerator {
    
    _progressSlider.value = 0.0;
    _playButton.selected = YES;
    
    _progressSlider.enabled = NO;
    _playButton.enabled = NO;
        
    self.kalturaPlayerViewController = [KalturaPlayerViewController kalturaPlayer];
    if (_kalturaPlayerViewController) {
        
        [self p_prepareConfigurations];
        [self p_reloadCurrentConfiguration];
        
        [self addChildViewController:_kalturaPlayerViewController];
        [self.view addSubview:_kalturaPlayerViewController.view];
        
        _kalturaPlayerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        
        [self.view bringSubviewToFront:_playButton];
        [self.view bringSubviewToFront:_progressSlider];
    }
}

- (void) p_removePlayerFromSuperView {
    
    [self.kalturaPlayerViewController removePlayer];
    
    [self.kalturaPlayerViewController.view removeFromSuperview];
    [self.kalturaPlayerViewController removeFromParentViewController];
}

- (void) p_reloadCurrentConfiguration {
    
    [_kalturaPlayerViewController reloadConfigureWithUiConfId: kSecondUIConfigurationViewControllerUIConfId
                                                    partnerId: kSecondUIConfigurationViewControllerPartnerId
                                                      entryId: kSecondUIConfigurationViewControllerEntryId
                                                     delegate: self
                                             prepareConfBlock: _prepareConfBlock];
}

- (void) p_prepareConfigurations {
    
    self.prepareConfBlock = ^(KPPlayerConfig *config) {
        
                                [config addConfigKey:@"controlBarContainer.plugin" withValue:@"false"];
                                [config addConfigKey:@"topBarContainer.plugin" withValue:@"false"];
                                [config addConfigKey:@"largePlayBtn.plugin" withValue:@"false"];
        
                                NSString *adTagUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
                                
                                [config addConfigKey:@"doubleClick.adTagUrl" withValue:adTagUrl];
                                [config addConfigKey:@"doubleClick.plugin" withValue:@"true"];
        
                                [config addConfigKey:@"watermark.plugin" withValue:@"false"];
                            };
}

- (void) p_progressSliderInitializer {
    
    if (self.kalturaPlayerViewController != nil) {
        
        self.progressSlider.minimumValue = 0.0;
        self.progressSlider.maximumValue = [self.kalturaPlayerViewController duration];
        self.progressSlider.value = [self.kalturaPlayerViewController currentPlaybackTime];
        self.playButton.selected = YES;
    }
}

- (void) p_pausePlayer {
    
    if (_kalturaPlayerViewController != nil) {
        
        _playButton.enabled = NO;
        [_kalturaPlayerViewController pause];
    }
}

- (void) p_playPlayer {
    
    if (_kalturaPlayerViewController != nil) {
        
        _playButton.enabled = NO;
        [_kalturaPlayerViewController play];
    }
}

- (void) p_replayPlayer {
    
    if (_kalturaPlayerViewController != nil) {
        
        [_kalturaPlayerViewController replay];
    }
}

- (void) p_showNativeComponents {
    
    _progressSlider.hidden = NO;
    _playButton.hidden = NO;
}

- (void) p_hideNativeComponents {
    
    _progressSlider.hidden = YES;
    _playButton.hidden = YES;
}

#pragma mark - Actions

- (IBAction)didChangeProgressAtSlider:(id)sender {
    
    if (_kalturaPlayerViewController != nil) {
        
        [_kalturaPlayerViewController seekWithPlaybackTime:_progressSlider.value];
    }
}

- (IBAction) didClickPlayButton:(id)sender {
    
    if (_playButton.isSelected) {
        
        [self p_playPlayer];
    } else {
        
        [self p_pausePlayer];
    }
}

#pragma mark - KalturaPlayerViewControllerDelegate

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController mediaErrorWithParams: (NSString *)params {

    [self p_replayPlayer];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerErrorWithParams: (NSString *)params {
    
    [self p_replayPlayer];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController mediaLoadedWithParams: (NSString *)params {
    
    _progressSlider.enabled = YES;
    _playButton.enabled = YES;
    
    [self p_showNativeComponents];
    
    [self p_progressSliderInitializer];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPlayedWithParams: (NSString *)params {
    
    _playButton.enabled = YES;
    _playButton.selected = NO;
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPausedWithParams: (NSString *)params {
    
    _playButton.enabled = YES;
    _playButton.selected = YES;
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPlayEndWithParams: (NSString *)params {
    
    _playButton.selected = NO;
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController preSeekWithParams: (NSString *)params {
    
    [self p_pausePlayer];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController seekedWithParams: (NSString *)params {
    
    [self p_playPlayer];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController timeupdateWithCurrentTime: (NSNumber *) time {
    
    _progressSlider.value = time.doubleValue;
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdPlayWithParams: (NSString *)params {
    
    [self p_hideNativeComponents];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdCompleteWithParams: (NSString *)params {
    
    [self p_showNativeComponents];
}

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdSkipWithParams: (NSString *)params {
    
    [self p_showNativeComponents];
}

- (void)kalturaPlayerViewController:(KalturaPlayerViewController *)viewController adClickWithParams:(NSString *)params {
    
     [self p_showNativeComponents];
}

@end
