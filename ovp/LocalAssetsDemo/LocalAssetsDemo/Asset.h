//
//  Asset.h
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 21/09/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Asset : NSObject
@property (nonatomic, copy) NSString* downloadUrl;
@property (nonatomic, copy) NSString* localName;
@property (nonatomic, copy) NSString* entryId;
@property (nonatomic, copy) NSString* flavorId;
@property (nonatomic, readonly) NSString* pathExtension;

@property (nonatomic, readonly) NSURL* targetURL;
@property (nonatomic, readonly) NSString* targetFile;
@property (nonatomic, readonly) NSString* playbackUrl;
@property (readonly) BOOL downloaded;

+(instancetype)assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url;
@end


typedef void(^kDownloadProgressReport)(float progress);
