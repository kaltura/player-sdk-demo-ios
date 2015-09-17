//
//  PartialPlayerViewController.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 6/1/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "PartialPlayerViewController.h"

@interface PartialPlayerViewController() {
    
    __weak IBOutlet UIView *playerHolderView;
}

@end

@implementation PartialPlayerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seek) name:KPMediaPlaybackStateDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _player.view.frame = playerHolderView.bounds;
    [_player loadPlayerIntoViewController:self];
    [playerHolderView addSubview:_player.view];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [_player removePlayer];
        _player = nil;
    }];
}

- (void)seek {
    [_player sendNotification:@"doSeek" withParams: @(22.55).stringValue];
}
@end
