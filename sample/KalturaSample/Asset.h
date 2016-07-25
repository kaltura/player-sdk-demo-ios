//
//  Asset.h
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/17/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Asset : NSObject

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *localName;
@property (nonatomic, copy) NSString *entryId;
@property (nonatomic, copy) NSString *flavorId;

@property (nonatomic, readonly) NSString *targetFile;
@property (nonatomic, readonly) NSString *playbackUrl;
@property (readonly) BOOL downloaded;

+ (instancetype)assetWithName:(NSString *)localName entry:(NSString *)entryId flavor:(NSString *)flavorId url:(NSString *)url;

@end
