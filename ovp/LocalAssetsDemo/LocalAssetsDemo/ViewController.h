//
//  ViewController.h
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 18/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@property (nonatomic) IBOutlet UIView* playerContainer;
@property (nonatomic) IBOutlet UIButton* downloadButton;
@property (nonatomic) IBOutlet UISwitch* contentSwitch;

@property (nonatomic) IBOutlet UITextField* assetPicker;

@end

