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


@interface Asset : NSObject
@property (nonatomic, copy) NSString* downloadUrl;
@property (nonatomic, copy) NSString* localName;
@property (nonatomic, copy) NSString* entryId;
@property (nonatomic, copy) NSString* flavorId;

@property (nonatomic, readonly) NSString* targetFile;
@property (nonatomic, readonly) NSString* playbackUrl;
@property (readonly) BOOL downloaded;

+(instancetype)assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url;
@end


