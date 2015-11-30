//
//  KPlayerTableViewCell.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 9/17/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "KPlayerTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface KPlayerTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation KPlayerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _iconImageView.layer.cornerRadius = 5.0;
}

- (void)setPlayerName:(NSString *)playerName {
    _playerNameLabel.text = playerName;
}

- (void)setIcon:(UIImage *)icon {
    [_spinner stopAnimating];
    _iconImageView.image = icon;
}

@end
