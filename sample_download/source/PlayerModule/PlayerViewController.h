//
//  PlayerViewController.h
//  KalturaDownloadSample
//
//  Created by Vitaliy Rusinov on 8/18/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlainObject.h"
#import <KALTURAPlayerSDK/KPViewController.h>
#import <KalturaPlayerSDK/KPLocalAssetsManager.h>

static NSString * const kShowDetailPlayerViewController = @"ShowDetailPlayerViewController";

@interface PlayerViewController : UIViewController

- (void) shouldUpdateCurrentModuleWithMediaPlainObject: (MediaPlainObject *)plain;

@end
