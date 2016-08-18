//
//  OfflineViewController.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/18/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "OfflineViewController.h"
#import "KalturaPlayerViewController.h"

static NSString * const kOfflineViewControllerUIConfId = @"35748841";
static NSString * const kOfflineViewControllerPartnerId = @"2164401";
static NSString * const kOfflineViewControllerEntryId = @"1_jqt5xrs1";
static NSString * const kOfflineViewControllerFlavorId = @"1_t44vxdmb";

@interface OfflineViewController ()

@property (nonatomic, strong) KalturaPlayerViewController *kpv;

@end

@implementation OfflineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.kpv = [KalturaPlayerViewController kalturaPlayer];
    if (_kpv) {
        
        [_kpv reloadConfigureWithName: @"cat.mp4" 
                             uiConfId:kOfflineViewControllerUIConfId 
                            partnerId:kOfflineViewControllerPartnerId 
                                entry:kOfflineViewControllerEntryId 
                               flavor:kOfflineViewControllerFlavorId
                        offlineEnable:YES
                             delegate:nil];
        
        [self addChildViewController:_kpv];
        [self.view addSubview:_kpv.view];
        
        _kpv.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    }
}

@end
