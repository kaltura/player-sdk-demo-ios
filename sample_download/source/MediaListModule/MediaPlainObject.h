//
//  MediaPlainObject.h
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaPlainObject : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) UIImage *image;

@property (nonatomic, copy) NSString *entryId;
@property (nonatomic, copy) NSString *flavorId;
@property (nonatomic, copy) NSString *partnerId;
@property (nonatomic, copy) NSString *uiconfId;

@property (nonatomic, assign) BOOL downloaded;

@end
