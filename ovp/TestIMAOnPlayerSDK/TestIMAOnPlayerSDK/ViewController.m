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
        NSString *adTagUrl = @"http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=xml_vmap1&unviewed_position_start=1&cust_params=sample_ar%3Dpremidpost&cmsid=496&vid=short_onecue&correlator=[timestamp]";
        
        // Account Params
        KPPlayerConfig *config = config = [[KPPlayerConfig alloc] initWithDomain:@"http://cdnapi.kaltura.com"
                                                                        uiConfID:@"26698911"
                                                                       partnerId:@"1831271"];
        
        [config addConfigKey:@"doubleClick.adTagUrl"        withValue:adTagUrl];
        [config addConfigKey:@"doubleClick.plugin"          withValue:@"true"];
        [config addConfigKey:@"doubleClick.leadWithFlash"   withValue:@"false"];
        
        
        // Video Entry
        config.entryId = @"1_1fncksnw";
        
        // Setting this property will cache the html pages in the limit size
        config.cacheSize = 0.8;
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