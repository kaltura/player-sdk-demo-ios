//
//  Asset.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 21/09/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "Asset.h"
@import AVFoundation;

@implementation Asset

+(instancetype)assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url {
    Asset* asset = [Asset new];
    
    asset.downloadUrl = url;
    asset.localName = localName;
    asset.flavorId = flavorId;
    asset.entryId = entryId;
    
    return asset;
}

-(NSString *)pathExtension {
    return self.downloadUrl.pathExtension;
}

-(BOOL)downloaded {
    NSString* path = self.targetURL.path;
    if ([path hasSuffix:@".movpkg"]) {
        return YES;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


-(NSString *)playbackUrl {
    return self.downloaded ? self.targetURL.absoluteString : nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", _localName, self.downloaded ? @"⬇︎" : @"☁︎"];
}

-(NSURL*)targetURL {
    NSString* location = [[NSUserDefaults standardUserDefaults] objectForKey:_localName];
    if (location) {
        NSURL* url = [[NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES] URLByAppendingPathComponent:location];
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSLog(@"playable? %d", [asset assetCache].playableOffline);
        NSLog(@"Location: %@", location);
        //        NSLog(@"Home: %@", NSHomeDirectory());
        return url;
    }
    NSURL* docDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    return [NSURL fileURLWithPath:_localName relativeToURL:docDir];
}

-(NSString *)targetFile {
    return [self targetURL].path;
}


@end
