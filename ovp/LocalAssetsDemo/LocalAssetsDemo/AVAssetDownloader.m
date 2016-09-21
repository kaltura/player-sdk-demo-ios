//
//  AVAssetDownloader.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 20/09/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "AVAssetDownloader.h"
#import <KalturaPlayerSDK/KPAssetRegistrationHelper.h>
#import "ViewController.h"


@implementation AVAssetDownloader

- (void)startDownload {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LocalAssetsDemo"];
    
    NSURL* downloadUrl = [NSURL URLWithString:self.asset.downloadUrl];

    NSError* error;
    AVURLAsset* urlAsset = [AVURLAsset assetWithURL:downloadUrl];
    [self.assetRegistrationHelper prepareAssetForDownload:urlAsset error:&error];
    
    AVAssetDownloadURLSession *session = [AVAssetDownloadURLSession sessionWithConfiguration:config assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    AVAssetDownloadTask* task = [session assetDownloadTaskWithURLAsset:urlAsset assetTitle:self.asset.localName assetArtworkData:nil options:nil];
    task.taskDescription = self.asset.localName;
    
    [task resume];
}

-(void)progressReport:(float)fraction {
    
}

@end


@implementation AVAssetDownloader (AssetDownload)


-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {
    
}

-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    [[NSUserDefaults standardUserDefaults] setObject:location.relativePath forKey:assetDownloadTask.taskDescription];
    self.progressReport(2);
}

-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    float fraction = (float)(timeRange.start.value+timeRange.duration.value) / timeRangeExpectedToLoad.duration.value;
    
    self.progressReport(fraction);
    
    NSLog(@"didLoadTimeRange: %lld (%lld); expected:  %lld", 
          timeRange.start.value/timeRange.start.timescale, timeRange.duration.value/timeRange.duration.timescale,
          timeRangeExpectedToLoad.duration.value/timeRangeExpectedToLoad.duration.timescale);

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    AVAssetDownloadTask* assetDownloadTask = (AVAssetDownloadTask *)task;
    NSLog(@"asset %@ completed; error? %@", assetDownloadTask.URLAsset.URL, error);
    if (error) {
        self.progressReport(-1);
    }
}


@end
