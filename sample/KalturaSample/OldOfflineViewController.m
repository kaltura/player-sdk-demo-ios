//
//  OfflineViewController.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/18/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "OfflineViewController.h"

//static NSString * const kOfflineViewControllerUIConfId = @"31956421";
//static NSString * const kOfflineViewControllerPartnerId = @"1851571";
//static NSString * const kOfflineViewControllerEntryId = @"1_aegxx56o";

static NSString * const kOfflineViewControllerUIConfId = @"35748841";
static NSString * const kOfflineViewControllerPartnerId = @"2164401";
static NSString * const kOfflineViewControllerEntryId = @"1_jqt5xrs1";

@interface OfflineViewController () <NSURLSessionDelegate, KPSourceURLProvider, KPViewControllerDelegate>

@property (nonatomic, strong) Asset *localAsset;
@property (nonatomic, strong) KPViewController *kpv;

@end

@implementation OfflineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.localAsset = [Asset assetWithName:@"cat.mp4"
                                     entry:@"1_jqt5xrs1"
                                    flavor:@"1_t44vxdmb"
                                       url:@"http://cfvod.kaltura.com/pd/p/2164401/sp/216440100/serveFlavor/entryId/1_jqt5xrs1/v/11/flavorId/1_t44vxdmb/name/a.mp4"];

    
    if (_kpv == nil) {
        
        _kpv = [[KPViewController alloc] initWithConfiguration: [OfflineViewController p_configureWithAsset:_localAsset]];
        [_kpv setCustomSourceURLProvider: self];
        [_kpv setDelegate: self];
        
        _kpv.view.frame = self.view.bounds;
        [self addChildViewController:_kpv];
        [self.view addSubview:_kpv.view];
    } else {
        
        [_kpv changeConfiguration: [OfflineViewController p_configureWithAsset:_localAsset]];
    }
    
    if (!self.localAsset.downloaded) {
        
        [self p_startDownload];
    }
}


#pragma mark - Private

+ (KPPlayerConfig *) p_configureWithAsset:(Asset *)asset {
    
    KPPlayerConfig* config;
    config = [[KPPlayerConfig alloc]
              initWithServer:@"http://cdnapi.kaltura.com"
              uiConfID:kOfflineViewControllerUIConfId partnerId:kOfflineViewControllerPartnerId];
    
    config.cacheSize = 100;
    config.entryId = asset.entryId;
    config.localContentId = asset.localName;
    
    return config;
}

- (void) p_registerAssetWithConfig: (KPPlayerConfig *)config favorId: (NSString *)favorId targetFile: (NSString *) targetFile {
    
    NSLog(@"file info: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:targetFile error:nil]);
    
    [KPLocalAssetsManager registerAsset:config flavor:favorId path:targetFile callback:^(NSError *error) {
        NSLog(@"Done:%@", error);
    }];
}

- (void) p_startDownload {
    
    NSURLSession *session = [self configureSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL: [NSURL URLWithString:self.localAsset.downloadUrl]];
    [task resume];
}

#pragma mark - Download

- (NSURLSession *) configureSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    return session;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *percent = [NSString stringWithFormat:@"%lld%%", 100 * totalBytesWritten/totalBytesExpectedToWrite];
    NSLog(@"downloaded %@", percent);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    // unused in this example
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSError *moveError;
    if (![[NSFileManager defaultManager] removeItemAtPath:self.localAsset.targetFile error:&moveError]) {
        NSLog(@"Delete error: %@", moveError);
    }
    
    if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.localAsset.targetFile error:&moveError]) {
        NSLog(@"Move error: %@", moveError);
        return;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"completed; error: %@", error);
    if (!error) {
        
        [self p_registerAssetWithConfig:[OfflineViewController p_configureWithAsset:_localAsset]
                                favorId:@"1_t44vxdmb"
                             targetFile:_localAsset.targetFile];
    }
}

#pragma mark - KPSourceURLProvider

- (NSString *)urlForEntryId:(NSString *)entryId currentURL:(NSString*)current {
    
    return [_localAsset playbackUrl];
}

@end
