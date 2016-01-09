//
//  ViewController.m
//  KChromecastDemo
//
//  Created by Eliza Sapir on 07/12/2015.
//  Copyright © 2015 Kaltura. All rights reserved.
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
        KPPlayerConfig *config = config = [[KPPlayerConfig alloc] initWithDomain:@"http://cdnapi.kaltura.com"
                                                                        uiConfID:@"26698911"
                                                                       partnerId:@"1831271"];

        [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
        // Set AutoPlay as configuration on player (same like setting a flashvar)
        [config addConfigKey:@"autoPlay" withValue:@"true"];
        
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
    //Present view controller - Fullscreen view
    [self presentViewController:self.player animated:YES completion:nil];
}

@end
