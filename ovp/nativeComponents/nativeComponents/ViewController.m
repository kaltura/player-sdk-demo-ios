//
//  ViewController.m
//  nativeComponents
//
//  Created by Eliza Sapir on 15/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "ViewController.h"
#import <KALTURAPlayerSDK/KPViewController.h>

@interface ViewController () 
@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (retain, nonatomic) KPViewController *player;
@end

@implementation ViewController {
    KPPlayerConfig *config;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    Present view controller - inline view
    self.player.view.frame = (CGRect){0, 0, 300, 200};
    [self.player loadPlayerIntoViewController:self];
    [self.playerContainer addSubview:_player.view];
//    Since there is controls view attached on storyboard
    [self.playerContainer sendSubviewToBack:_player.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (KPViewController *)player {
    if (!_player) {
        config = [[KPPlayerConfig alloc] initWithDomain:@"http://cdnapi.kaltura.com"
                                               uiConfID:@"32855491"
                                              partnerId:@"1424501"];
        
        config.entryId = @"1_ypo9wae3";
        [self hideHTMLControls];
        _player = [[KPViewController alloc] initWithConfiguration:config];
    }

    return _player;
}

- (void)hideHTMLControls {
    [config addConfigKey:@"controlBarContainer.plugin" withValue:@"false"];
    [config addConfigKey:@"topBarContainer.plugin" withValue:@"false"];
    [config addConfigKey:@"largePlayBtn.plugin" withValue:@"false"];
}

- (void)play {
    [self.player.playerController play];
}

- (void)pause {
    [self.player.playerController pause];
}

- (void)timeScrubberChange:(UISlider*)slider {
    slider.maximumValue =  self.player.playerController.duration;
    self.player.playerController.currentPlaybackTime = slider.value;
}

@end
