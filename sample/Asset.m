//
//  Asset.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/17/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "Asset.h"

@implementation Asset

+ (instancetype) assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url {
    
    Asset *asset = [Asset new];
    
    asset.downloadUrl = url;
    asset.localName = localName;
    asset.flavorId = flavorId;
    asset.entryId = entryId;
    
    return asset;
}

- (BOOL) downloaded {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.targetFile];
}


- (NSString *) playbackUrl {
    
    if (self.downloaded) {
        
        return [NSURL fileURLWithPath:self.targetFile].absoluteString;
    } else {
        
        return self.downloaded ? self.targetFile : nil;
    }
}

- (NSString *) description {
    
    return [NSString stringWithFormat:@"%@ %@", _localName, self.downloaded ? @"⬇︎" : @"☁︎"];
}

- (NSString *) targetFile {
    
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docDir stringByAppendingPathComponent:_localName];
} 

@end
