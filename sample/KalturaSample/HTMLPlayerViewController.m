//
//  SecondViewController.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/6/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "HTMLPlayerViewController.h"
#import "KalturaPlayerViewController.h"

static NSString * const kFirstUIConfigurationViewControllerUIConfId = @"35750171";
static NSString * const kFirstUIConfigurationViewControllerPartnerId = @"2164401";
static NSString * const kFirstUIConfigurationViewControllerEntryId = @"1_jqt5xrs1";

@interface HTMLPlayerViewController ()

@property (nonatomic, strong) KalturaPlayerViewController *kalturaPlayerViewController;

@end

@implementation HTMLPlayerViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self playerModerator];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self removePlayerFromSuperView];
}

- (void)playerModerator {
    
    self.kalturaPlayerViewController = [KalturaPlayerViewController kalturaPlayer];
    if (_kalturaPlayerViewController) {
        
        [_kalturaPlayerViewController reloadConfigureWithUiConfId: kFirstUIConfigurationViewControllerUIConfId
                                                        partnerId: kFirstUIConfigurationViewControllerPartnerId
                                                          entryId: kFirstUIConfigurationViewControllerEntryId
                                                         delegate: nil
                                                 prepareConfBlock:^(KPPlayerConfig *config) {
                                                     
                                                    NSString *adTagUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
                                                     
                                                     [config addConfigKey:@"doubleClick.adTagUrl" withValue:adTagUrl];
                                                     [config addConfigKey:@"doubleClick.plugin" withValue:@"true"];
                                                 }];
        
        [self addChildViewController:_kalturaPlayerViewController];
        [self.view addSubview:_kalturaPlayerViewController.view];
        
        _kalturaPlayerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds ), CGRectGetHeight(self.view.bounds));
    }
}

- (void)removePlayerFromSuperView {
        
    [self.kalturaPlayerViewController removePlayer];
    
    [self.kalturaPlayerViewController.view removeFromSuperview];
    [self.kalturaPlayerViewController removeFromParentViewController];
}

@end
