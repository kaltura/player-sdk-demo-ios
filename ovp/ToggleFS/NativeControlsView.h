//
//  NativeControlsView.h
//  nativeComponents
//
//  Created by Eliza Sapir on 15/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreMedia;

@protocol NativeControlsDelegate <NSObject>

@required
- (void)play;
- (void)pause;
- (void)timeScrubberChange:(UISlider*)slider;

@end

@interface NativeControlsView : UIView
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (nonatomic, weak) IBOutlet id <NativeControlsDelegate> delegate;
 
@end
