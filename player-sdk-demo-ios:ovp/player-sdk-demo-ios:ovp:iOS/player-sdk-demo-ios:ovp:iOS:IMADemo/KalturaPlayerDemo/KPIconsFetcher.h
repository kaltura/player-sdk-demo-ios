//
//  KPIconsFetcher.h
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 9/17/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KPIconsFetcher : NSObject
+ (void)fetchIconWithPartnerId:(NSString *)partnerId entryId:(NSString *)entryId completion:(void(^)(UIImage *icon, NSError *error))comletion;
@end
