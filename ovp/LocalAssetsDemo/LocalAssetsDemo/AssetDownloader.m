//
//  AssetDownloader.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 21/09/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "AssetDownloader.h"

#import "AVAssetDownloader.h"
#import <KalturaPlayerSDK/KPAssetRegistrationHelper.h>
#import "ViewController.h"


@interface SingleFileAssetDownloader : AssetDownloader <NSURLSessionDownloadDelegate>
@end


@implementation AssetDownloader

+(AssetDownloader*)downloaderForAsset:(Asset*)asset config:(KPPlayerConfig*)config {
    AssetDownloader* downloader;
    Class downloaderClass;
    
    if ([asset.pathExtension isEqualToString:@"m3u8"]) {
        downloaderClass = NSClassFromString(@"AVAssetDownloader");
        if (!downloaderClass) {
            NSLog(@"Error: can't download HLS/FPS");
            return nil;
        }
    } else {
        downloaderClass = [SingleFileAssetDownloader class];
    }
    
    downloader = [[downloaderClass alloc] initWithAsset:asset config:config];
    
    return downloader;    
}

- (instancetype)initWithAsset:(Asset*)asset config:(KPPlayerConfig*)config
{
    self = [super init];
    if (self) {
        self.asset = asset;
        self.assetRegistrationHelper = [KPAssetRegistrationHelper helperForAsset:config flavor:asset.flavorId];
        self.progressReport = ^(float progress) {
            NSLog(@"progress: %.02f", progress);
        };
    }
    return self;
}

-(void)startDownload {
    
}

@end



@implementation SingleFileAssetDownloader

- (void)startDownload {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LocalAssetsDemo"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:[NSURL URLWithString:self.asset.downloadUrl]];
    [task resume];
    
    self.progressReport(0);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    self.progressReport(1.0*totalBytesWritten/totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // Regular download -- now move to target path.
    
    NSError* moveError;
    if (![[NSFileManager defaultManager] removeItemAtPath:self.asset.targetFile error:&moveError]) {
        //        NSLog(@"Delete error: %@", moveError);
    }
    
    if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.asset.targetFile error:&moveError]) {
        NSLog(@"Move error: %@", moveError);
        return;
    }
    
    self.progressReport(2);
}

@end
