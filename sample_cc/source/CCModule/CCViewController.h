//
//  CCViewController.h
//  KalturaSample
//
//  Created by Vitaliy Rusinov on 7/20/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kShowCCViewController = @"ShowCCViewController";

@interface CCViewController : UIViewController

- (void) shouldUpdateWithEntryId: (NSString *) entryId;

@end
