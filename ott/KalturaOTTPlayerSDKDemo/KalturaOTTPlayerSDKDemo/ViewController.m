//
//  ViewController.m
//  KalturaOTTPlayerSDKDemo
//
//  Created by Eliza Sapir on 29/11/2015.
//  Copyright © 2015 Kaltura. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (KPViewController *)player {
    if (!_player) {
        // Kaltura Account Params
        KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithDomain:@"http://player-stg-eu.ott.kaltura.com/viacomIN/v2.37.2/mwEmbed/mwEmbedFrame.php"
                                                               uiConfID:@"8413353"
                                                              partnerId:@""];
        
        
        // Kaltura Video Media ID (equals to entry id)
        config.entryId = @"295868";
        
        [config addConfigKey:@"liveCore.disableLiveCheck" withValue:@"true"];
        [config addConfigKey:@"tvpapiGetLicensedLinks.plugin" withValue:@"true"];
        
        NSDictionary *proxyDataDict = @{@"initObj"      : [self getInitObjectDictionary],
                                        @"MediaID"      : config.entryId,
                                        @"iMediaID"     : config.entryId,
                                        @"picSize"      : @"640x360",
                                        @"mediaType"    : @"0",
                                        @"withDynamic"  : @"false"};
        
        
        [config addConfigKey:@"proxyData" withDictionary:proxyDataDict];
        [config addConfigKey:@"TVPAPIBaseUrl" withValue:@"http://stg.eu.tvinci.com/tvpapi_v3_3/gateways/jsonpostgw.aspx?m="];
        
        // Setting this property will cache the html pages in the limit size
        config.cacheSize = 0.8;
        _player = [[KPViewController alloc] initWithConfiguration:config];
    }
    return _player;
}

- (NSDictionary *)getInitObjectDictionary {
    NSDictionary *localeDict = @{@"LocaleLanguage": @"",
                                 @"LocaleCountry": @"",
                                 @"LocaleDevice": @"",
                                 @"LocaleUserState": @"Unknown"
                                 };
    
    NSDictionary *initObjectDict = @{@"Locale"      : localeDict,
                                     @"Platform": @"Cellular",
                                     @"SiteGuid": @"613999" ,
                                     @"DomainID": @"282563",
                                     @"UDID": @"123456",
                                     @"ApiUser": @"tvpapi_225",
                                     @"ApiPass": @"11111"};
    
    return initObjectDict;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Present view controller - Fullscreen view
    [self presentViewController:self.player animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
