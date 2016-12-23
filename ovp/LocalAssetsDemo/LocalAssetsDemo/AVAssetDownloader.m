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


@interface AVAssetDownloader ()
@property (nonatomic) NSMutableDictionary<AVAssetDownloadTask*, AVMediaSelection*>* mediaSelection;
/// Internal map of AVAssetDownloadTask to its corresponding Asset.
@property (nonatomic) NSMutableDictionary<AVAssetDownloadTask*, Asset*>* activeDownloadsMap;

@property (strong, nonatomic) AVAssetDownloadURLSession *assetDownloadURLSession;
@end

@interface MediaSelectionTuple : NSObject
@property (nonatomic, nullable) AVMediaSelectionGroup* group;
@property (nonatomic, nullable) AVMediaSelectionOption* option;
@end

@implementation MediaSelectionTuple

- (instancetype)initWithGroup:(AVMediaSelectionGroup*)group option:(AVMediaSelectionOption*)option {
    self = [super init];
    if (self) {
        self.group = group;
        self.option = option;
    }
    return self;
}

@end

@implementation AVAssetDownloader

///// Triggers the initial AVAssetDownloadTask for a given Asset.
//func downloadStream(for asset: Asset) {
//    /*
//     For the initial download, we ask the URLSession for an AVAssetDownloadTask
//     with a minimum bitrate corresponding with one of the lower bitrate variants
//     in the asset.
//     */
//    guard let task = assetDownloadURLSession.makeAssetDownloadTask(asset: asset.urlAsset, assetTitle: asset.name, assetArtworkData: nil, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265000]) else { return }
//    
//    // To better track the AVAssetDownloadTask we set the taskDescription to something unique for our sample.
//    task.taskDescription = asset.name
//    
//    activeDownloadsMap[task] = asset
//    
//    task.resume()
//    
//    var userInfo = [String: Any]()
//    userInfo[Asset.Keys.name] = asset.name
//    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue
//    
//    NotificationCenter.default.post(name: AssetDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
//}

- (void)startDownload {
    
    NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"AAPL-Identifier"];
    
    NSURL* downloadUrl = [NSURL URLWithString:self.asset.downloadUrl];

    NSError* error;
    AVURLAsset* urlAsset = [AVURLAsset assetWithURL:downloadUrl];
    [self.assetRegistrationHelper prepareAssetForDownload:urlAsset error:&error];
    
    
//    AVMutableMediaSelection* mediaSelection = [[AVMutableMediaSelection alloc] init];
//    NSDictionary* options = @{AVAssetDownloadTaskMediaSelectionKey: mediaSelection};
    
    // Create a new download task with this media selection in its options
    NSDictionary* downloadOptions = @{AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: @265000};
    
    self.assetDownloadURLSession = [AVAssetDownloadURLSession sessionWithConfiguration: backgroundConfiguration assetDownloadDelegate: self delegateQueue: [NSOperationQueue mainQueue]];
    AVAssetDownloadTask* task = [_assetDownloadURLSession assetDownloadTaskWithURLAsset:urlAsset assetTitle:self.asset.localName assetArtworkData:nil options: downloadOptions];
    
    if (task == nil) {
        
        return;
    } else {
        
        task.taskDescription = self.asset.localName;
        
        self.mediaSelection = [[NSMutableDictionary alloc] init];
        self.activeDownloadsMap = [[NSMutableDictionary alloc] init];
        
        self.activeDownloadsMap[task] = self.asset;
        
        [task resume];
    }
}

-(void)progressReport:(float)fraction {
    
}


// MARK: Convenience

/**
 This function demonstrates returns the next `AVMediaSelectionGroup` and
 `AVMediaSelectionOption` that should be downloaded if needed. This is done
 by querying an `AVURLAsset`'s `AVAssetCache` for its available `AVMediaSelection`
 and comparing it to the remote versions.
 */

-(MediaSelectionTuple*)nextMediaSelection:(AVURLAsset*)asset {
    AVAssetCache* assetCache = asset.assetCache;
    if (!assetCache) {
        return nil;
    }
    // Audio and subtitles
    NSArray* characteristics = @[AVMediaCharacteristicAudible, AVMediaCharacteristicLegible];
    // Audio
//    NSArray* characteristics = @[AVMediaCharacteristicAudible];
    // Subtitles
//    NSArray* characteristics = @[AVMediaCharacteristicLegible];
    
    for (NSString* characteristic in characteristics) {

        // Determine which offline media selection options exist for this asset
        AVMediaSelectionGroup *mediaSelectionGroup = [asset mediaSelectionGroupForMediaCharacteristic: characteristic];
        if (mediaSelectionGroup) {
            
            NSArray<AVMediaSelectionOption*>* savedOptions = [assetCache mediaSelectionOptionsInMediaSelectionGroup:mediaSelectionGroup];
            
            if (savedOptions.count < mediaSelectionGroup.options.count) {
                // There are still media options left to download.
                for (AVMediaSelectionOption* option in mediaSelectionGroup.options) {
                    if (![savedOptions containsObject:option]) {
                        
                        // This option hasn't been downloaded. Return it so it can be.
                        return [[MediaSelectionTuple alloc] initWithGroup:mediaSelectionGroup option:option];
                    }
                }
            }
        }
    }
    
    // At this point all media options have been downloaded.
    return nil;
}

@end


@implementation AVAssetDownloader (AssetDownload)


-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {
    
    self.mediaSelection[assetDownloadTask] = resolvedMediaSelection;    
    
    AVURLAsset* asset = assetDownloadTask.URLAsset;
    AVMediaSelectionGroup* visual = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicVisual];
    AVMediaSelectionGroup* audible = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];
    AVMediaSelectionGroup* legible = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    NSLog(@"V:%@ A:%@ L:%@", visual, audible, legible);
    NSLog(@"didResolveMediaSelection: %@", resolvedMediaSelection);
}

-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString* name = assetDownloadTask.taskDescription;
    if (name != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:location.relativePath forKey:name];
    }
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
    
    /*
     This is the ideal place to begin downloading additional media selections
     once the asset itself has finished downloading.
     */
    AVAssetDownloadTask *assetDownloadTask = (AVAssetDownloadTask *)task;
    Asset *downloadAsset = [_activeDownloadsMap objectForKey: assetDownloadTask];
    if (downloadAsset == nil || assetDownloadTask == nil) {
        
        return;
    }
    [_activeDownloadsMap removeObjectForKey: assetDownloadTask];
    
    NSLog(@"asset %@ completed; error? %@", assetDownloadTask.URLAsset.URL, error);
    if (error) {
        self.progressReport(-1);
        return;
    }
    
    // Download extra media selections
    
    // Determine the next available AVMediaSelectionOption to download
    MediaSelectionTuple *mediaSelectionPair = [self nextMediaSelection:assetDownloadTask.URLAsset];
    
    if (mediaSelectionPair.group != nil) {
        
        /*
         This task did complete sucessfully. At this point the application
         can download additional media selections if needed.
         
         To download additional `AVMediaSelection`s, you should use the
         `AVMediaSelection` reference saved in `AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didResolve:)`.
         */
        AVMutableMediaSelection *originalMediaSelection = (AVMutableMediaSelection *)_mediaSelection[assetDownloadTask];
        if (originalMediaSelection == nil) {
            
            return;
        } else {
            
            /*
             There are still media selections to download.
             
             Create a mutable copy of the AVMediaSelection reference saved in
             `AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didResolve:)`.
             */
            AVMutableMediaSelection *mediaSelection = (AVMutableMediaSelection *)[originalMediaSelection mutableCopy];
            AVMediaSelectionOption *option = mediaSelectionPair.option;
            AVMediaSelectionGroup *group = mediaSelectionPair.group;
            if (option && group) {
                 // Select the AVMediaSelectionOption in the AVMediaSelectionGroup we found earlier.
                [mediaSelection selectMediaOption: option inMediaSelectionGroup: group];
            }
            
            
            // Create a new download task with this media selection in its options
            NSDictionary* downloadOptions = @{AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: @2000000, AVAssetDownloadTaskMediaSelectionKey: mediaSelection};
            
            /*
             Ask the `URLSession` to vend a new `AVAssetDownloadTask` using
             the same `AVURLAsset` and assetTitle as before.
             
             This time, the application includes the specific `AVMediaSelection`
             to download as well as a higher bitrate.
             */
            AVAssetDownloadTask *nextTask = [_assetDownloadURLSession assetDownloadTaskWithURLAsset: assetDownloadTask.URLAsset assetTitle: downloadAsset.localName
                                                                                   assetArtworkData: nil options: downloadOptions];
            if (nextTask == nil) {
                
                return;
            } else {
                
                nextTask.taskDescription = downloadAsset.localName;
                self.activeDownloadsMap[nextTask] = downloadAsset;
                
                [nextTask resume];
            }
        }
    }
}

@end
