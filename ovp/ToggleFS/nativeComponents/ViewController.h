//
//  ViewController.h
//  nativeComponents
//
//  Created by Eliza Sapir on 15/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeControlsView.h"

@interface ViewController : UIViewController <NativeControlsDelegate>

- (void)play;
@property (weak, nonatomic) IBOutlet NativeControlsView *nativeControlsView;

@end

