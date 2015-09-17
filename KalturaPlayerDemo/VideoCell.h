//
//  VideoCell.h
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 8/2/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KALTURAPlayerSDK/KPViewController.h>

@interface VideoCell : UICollectionViewCell
@property (nonatomic, readonly) KPViewController *player;
@property (nonatomic, strong) UIViewController *parentController;
- (void)setEntryId:(NSString *)entryId;
@end
