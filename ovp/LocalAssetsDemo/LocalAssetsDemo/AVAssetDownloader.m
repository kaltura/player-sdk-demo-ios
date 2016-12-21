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

- (void)startDownload {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LocalAssetsDemo"];
    
    NSURL* downloadUrl = [NSURL URLWithString:self.asset.downloadUrl];

    NSError* error;
    AVURLAsset* urlAsset = [AVURLAsset assetWithURL:downloadUrl];
    [self.assetRegistrationHelper prepareAssetForDownload:urlAsset error:&error];
    
    
//    AVMutableMediaSelection* mediaSelection = [[AVMutableMediaSelection alloc] init];
//    NSDictionary* options = @{AVAssetDownloadTaskMediaSelectionKey: mediaSelection};
    
    
    AVAssetDownloadURLSession *session = [AVAssetDownloadURLSession sessionWithConfiguration:config assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    AVAssetDownloadTask* task = [session assetDownloadTaskWithURLAsset:urlAsset assetTitle:self.asset.localName assetArtworkData:nil options:nil];
    task.taskDescription = self.asset.localName;
    
    self.mediaSelection = [[NSMutableDictionary alloc] init];
    
    [task resume];
}

-(void)progressReport:(float)fraction {
    
}

-(MediaSelectionTuple*)nextMediaSelection:(AVURLAsset*)asset {
    AVAssetCache* assetCache = asset.assetCache;
    if (!assetCache) {
        return nil;
    }
    // Audio and subtitles
//    NSArray* characteristics = @[AVMediaCharacteristicAudible, AVMediaCharacteristicLegible];
    // Audio
//    NSArray* characteristics = @[AVMediaCharacteristicAudible];
    // Subtitles
    NSArray* characteristics = @[AVMediaCharacteristicLegible];
    
    for (NSString* characteristic in characteristics) {
        AVMediaSelectionGroup* mediaSelectionGroup = [asset mediaSelectionGroupForMediaCharacteristic:characteristic];
        
        // Determine which offline media selection options exist for this asset
        NSArray<AVMediaSelectionOption*>* savedOptions = [assetCache mediaSelectionOptionsInMediaSelectionGroup:mediaSelectionGroup];
        
        // If there are still media options to download...
        if (savedOptions.count < mediaSelectionGroup.options.count) {
            
            for (AVMediaSelectionOption* option in mediaSelectionGroup.options) {
                if (![savedOptions containsObject:option]) {
                    
                    // This option hasn't been downloaded. Return it so it can be.
                    return [[MediaSelectionTuple alloc] initWithGroup:mediaSelectionGroup option:option];
                }
            }
        }    
    }
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
    AVAssetDownloadTask* assetDownloadTask = (AVAssetDownloadTask *)task;
    NSLog(@"asset %@ completed; error? %@", assetDownloadTask.URLAsset.URL, error);
    if (error) {
        self.progressReport(-1);
        return;
    }
    
    // Download extra media selections

    // Determine the next available AVMediaSelectionOption to download
    MediaSelectionTuple* nextSelection = [self nextMediaSelection:assetDownloadTask.URLAsset];
    
    
    AVMediaSelectionGroup* group = nextSelection.group;
    
    // If an undownloaded media selection option exists in the group...
    if (group == nil) {
        // done
        return;
    }
    
    AVMediaSelectionOption* option = nextSelection.option;
    // Exit early if no corresponding AVMediaSelection exists for the current task
    if (self.mediaSelection[assetDownloadTask] == nil) {
        // done
        return;
    }
            
            
    // Create a mutable copy and select the media selection option in the media selection group
    AVMutableMediaSelection* mediaSelection = [self.mediaSelection[assetDownloadTask] mutableCopy];
    [mediaSelection selectMediaOption:option inMediaSelectionGroup:group];
    
    // Create a new download task with this media selection in its options
    NSDictionary* downloadOptions = @{AVAssetDownloadTaskMediaSelectionKey: mediaSelection};
    
    // Start media selection download
    AVAssetDownloadTask* nextTask = [((AVAssetDownloadURLSession*)session) assetDownloadTaskWithURLAsset:assetDownloadTask.URLAsset assetTitle:assetDownloadTask.taskDescription assetArtworkData:nil options:downloadOptions];
    [nextTask resume];
    
}


@end
