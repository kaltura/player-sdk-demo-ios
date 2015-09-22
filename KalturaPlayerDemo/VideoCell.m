//
//  VideoCell.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 8/2/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "VideoCell.h"


@interface VideoCell() {
    NSString  *_entryId;
}

@end

@implementation VideoCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadPlayer];
        return self;
    }
    return nil;
}

- (void)loadPlayer {
    KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithDomain:@"https://cdnapisec.kaltura.com"
                                                           uiConfID:@"26698911"
                                                           partnerId:@"1831271"];
    
    [config addConfigKey:@"autoPlay" withValue:@"true"];
    
    
    // Video Entry
    config.entryId = @"1_o426d3i4";
    _entryId = config.entryId;
    [config addConfigKey:@"nativeCallout.plugin"
               withValue:@"true"];
    
    _player = [[KPViewController alloc] initWithConfiguration:config];
}

- (void)setEntryId:(NSString *)entryId {
    if (![_entryId isEqualToString:entryId]) {
        _entryId = entryId;
        [_player changeMedia:entryId];
    }
}

- (void)setParentController:(UIViewController *)parentController {
    if (!_parentController) {
        _parentController = parentController;
        [_player loadPlayerIntoViewController:parentController];
        _player.view.frame = self.contentView.frame;
        [self.contentView addSubview:_player.view];
    }
}
@end
