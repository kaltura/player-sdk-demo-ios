//
//  ViewController.h
//  KalturaOTTPlayerSDKDemo
//
//  Created by Eliza Sapir on 29/11/2015.
//  Copyright © 2015 Kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
//Import KPViewController to main project
#import <KALTURAPlayerSDK/KPViewController.h>

@interface ViewController : UIViewController
//Create KPViewController instance
@property (retain, nonatomic) KPViewController *player;

@end

