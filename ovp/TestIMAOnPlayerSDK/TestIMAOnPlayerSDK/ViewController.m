//
//  ViewController.m
//  KalturaPlayerTestA_2_0_9
//
//  Created by Leslie Sanford on 11/4/15.
//  Copyright © 2015 Leslie Sanford. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (KPViewController *)player {
    if (!_player) {
        
        // Account Params
        KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithServer: @"http://cdnapi.kaltura.com"
                                                               uiConfID: @"35815611"
                                                              partnerId: @"2164401"];
        
        NSString *adTagUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
        
        [config addConfigKey:@"doubleClick.adTagUrl" withValue:adTagUrl];
        [config addConfigKey:@"doubleClick.plugin" withValue:@"true"];

        // Video Entry
        config.entryId = @"1_jqt5xrs1";
        
        _player = [[KPViewController alloc] initWithConfiguration:config];
    }
    return _player;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Present view controller - inline view
//    self.player.view.frame = (CGRect){0, 0, 320, 180};
//    [self.player loadPlayerIntoViewController:self];
//    [self.view addSubview:_player.view];
    //Present view controller - Fullscreen view
    [self presentViewController:self.player animated:YES completion:nil];
}

@end