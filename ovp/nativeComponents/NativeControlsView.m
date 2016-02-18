//
//  NativeControlsView.m
//  nativeComponents
//
//  Created by Eliza Sapir on 15/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "NativeControlsView.h"

@implementation NativeControlsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    if (self) {
        if (self.subviews.count == 0) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
            NativeControlsView *subview = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
            subview.frame = self.bounds;
            [self addSubview:subview];
        }
    }
    return self;
}

- (void)layoutSubviews {
    NativeControlsView *subview  = self.subviews.firstObject;
    if ([subview isKindOfClass:[NativeControlsView class]]) {
        subview.delegate = self.delegate;
    }

}

- (IBAction)play:(id)sender {
    if ([self.playBtn.titleLabel.text isEqual:@"Play"] &&
        [_delegate respondsToSelector:@selector(play)]) {
        [_delegate play];
        [self.playBtn setTitle:@"Pause" forState:UIControlStateNormal];
    } else if ([_delegate respondsToSelector:@selector(pause)]) {
        [_delegate pause];
        [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)timeScrubberChange:(id)sender {
    if ([_delegate respondsToSelector:@selector(timeScrubberChange:)]) {
        [_delegate timeScrubberChange:sender];
    }
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        if (self.subviews.count == 0) {
//            UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
//            UIView *subview = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//            subview.frame = self.bounds;
//            [self addSubview:subview];
//        }
//    }
//    return self;
//}

@end
