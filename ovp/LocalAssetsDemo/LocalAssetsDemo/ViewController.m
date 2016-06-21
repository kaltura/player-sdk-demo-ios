//
//  ViewController.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 18/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

// Note to users of this demo app:
// Find the places that say TODO to customize the demo.

#import "ViewController.h"

#import <KalturaPlayerSDK/KPPlayerConfig.h>
#import <KalturaPlayerSDK/KPLocalAssetsManager.h>
#import <KalturaPlayerSDK/KPURLProtocol.h>
#import <KalturaPlayerSDK/KCacheManager.h>

#import <KalturaPlayerSDK/KPViewController.h>

#import <DownPicker/DownPicker.h>

@class Asset;

@interface ViewController ()
@property (nonatomic) KPViewController* kpv;
@property (strong, nonatomic) DownPicker* picker;
@property (nonatomic, readonly) Asset* selectedAsset;
@property (nonatomic) NSArray<Asset*>* assets;
@end

@interface ViewController (KalturaPlayer) <KPViewControllerDelegate, KPSourceURLProvider>
@end

@interface ViewController (WebView) <UIWebViewDelegate>
@end

@interface ViewController (Download) <NSURLSessionDownloadDelegate>
- (void)startDownload;
@end


@interface Asset : NSObject
@property (nonatomic, copy) NSString* downloadUrl;
@property (nonatomic, copy) NSString* localName;
@property (nonatomic, copy) NSString* entryId;
@property (nonatomic, copy) NSString* flavorId;

@property (nonatomic, readonly) KPPlayerConfig* config;
@property (nonatomic, readonly) NSString* targetFile;
@property (nonatomic, readonly) NSString* playbackUrl;
@property (readonly) BOOL downloaded;

+(instancetype)assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url;
@end

@implementation Asset

+(instancetype)assetWithName:(NSString*)localName entry:(NSString*)entryId flavor:(NSString*)flavorId url:(NSString*)url {
    Asset* asset = [Asset new];
    
    asset.downloadUrl = url;
    asset.localName = localName;
    asset.flavorId = flavorId;
    asset.entryId = entryId;
    
    return asset;
}

-(KPPlayerConfig *)config {
    
    // TODO: set server, uiconfid, partnerId
    KPPlayerConfig* config;
    config = [[KPPlayerConfig alloc] 
              initWithServer:@"https://cdnapisec.kaltura.com" 
              uiConfID:@"31956421" partnerId:@"1851571"];    
    
    config.entryId = _entryId;
    config.localContentId = self.downloaded ? _localName : nil;
    config.cacheSize = 100; // TODO: set cachesize (optional), in MB
    
    return config;
}

-(BOOL)downloaded {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.targetFile];
}


-(NSString *)playbackUrl {
    if (self.downloaded) {
        return [NSURL fileURLWithPath:self.targetFile].absoluteString;
    } else {
        return self.downloaded ? self.targetFile : nil;
    }

}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", _localName, self.downloaded ? @"⬇︎" : @"☁︎"];
}

-(NSString *)targetFile {
    NSString* docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docDir stringByAppendingPathComponent:_localName];
}


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: modify the array of assets. 
    // Assets that are not meant to be downloaded can have nil as the flavor and url.
    _assets = @[
                [Asset assetWithName:@"sintel.wvm" entry:@"0_pl5lbfo0" flavor:@"1_e0qtaj1j" url:@"http://cdnapi.kaltura.com/p/1851571/sp/185157100/playManifest/entryId/0_pl5lbfo0/flavorId/1_e0qtaj1j/format/url/protocol/http/a.wvm"],
                [Asset assetWithName:@"count.wvm" entry:@"0_uafvpmv8" flavor:@"0_2rl0w6f1" url:@"http://cdnapi.kaltura.com/p/1851571/sp/185157100/playManifest/entryId/0_uafvpmv8/flavorId/0_2rl0w6f1/format/url/protocol/http/a.wvm"],
                [Asset assetWithName:@"cat.mp4" entry:@"1_aegxx56o" flavor:@"1_6dadj61z" url:@"http://cfvod.kaltura.com/pd/p/1851571/sp/185157100/serveFlavor/entryId/1_aegxx56o/v/11/flavorId/1_6dadj61z/name/a.mp4"],
                ];
    
    _picker = [[DownPicker alloc] initWithTextField:_assetPicker withData:[_assets valueForKey:@"description"]];
    [_picker addTarget:self action:@selector(assetSelected:) forControlEvents:UIControlEventValueChanged];
    _picker.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(Asset *)selectedAsset {
    return _assets[_picker.selectedIndex];
}

-(IBAction)assetSelected:(id)sender {
    [KCacheManager shared].baseURL = [self.selectedAsset.config server];
}

-(IBAction)statusTapped:(UIButton*)button {
    
    [KPLocalAssetsManager checkStatusForAsset:self.selectedAsset.config path:self.selectedAsset.targetFile callback:^(NSError *error, NSTimeInterval expiryTime, NSTimeInterval availableTime) {
        NSLog(@"status: %d -- %d -- error: %@", (int)expiryTime, (int)availableTime, error);
    }];
}

-(IBAction)playTapped:(UIButton*)button {
    
    if (!_kpv) {
        KPViewController* kpv = [[KPViewController alloc] initWithConfiguration:self.selectedAsset.config];
        [kpv setCustomSourceURLProvider:self];
        [kpv setDelegate:self];
        
        kpv.view.frame = _playerContainer.bounds;
        [self addChildViewController:kpv];
        [_playerContainer addSubview:kpv.view];
        
        _kpv = kpv;
    } else {
        [_kpv changeConfiguration:self.selectedAsset.config];
    }
}

-(IBAction)loadTapped:(UIButton*)button {
    NSLog(@"loadTapped:%@", button);
    
    [self startDownload];
    
}

-(IBAction)registerTapped:(UIButton*)button {
    NSLog(@"registerTapped:%@", button);
    
    button.backgroundColor = [UIColor yellowColor];
    
    NSLog(@"file info: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:self.selectedAsset.targetFile error:nil]);
    
    [KPLocalAssetsManager registerAsset:self.selectedAsset.config flavor:self.selectedAsset.flavorId path:self.selectedAsset.targetFile callback:^(NSError *error) {
        NSLog(@"Done:%@", error);
        UIColor* color = error ? [UIColor redColor] : [UIColor whiteColor];
        [button performSelectorOnMainThread:@selector(setBackgroundColor:) withObject:color waitUntilDone:NO];
    }];
}

@end

@implementation ViewController (KalturaPlayer)

-(NSString*)urlForEntryId:(NSString *)entryId currentURL:(NSString *)current {
    
    NSAssert([entryId isEqualToString:self.selectedAsset.entryId], @"Demo: assuming we're playing the selected asset");
    
    return self.selectedAsset.playbackUrl;
}


@end


@implementation ViewController (Download)

- (void)startDownload
{
    NSURLSession* session = [self configureSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:self.selectedAsset.downloadUrl]];
    [task resume];
    
    _downloadButton.backgroundColor = [UIColor yellowColor];
}

- (NSURLSession *) configureSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return session;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString* percent = [NSString stringWithFormat:@"%lld%%", 100*totalBytesWritten/totalBytesExpectedToWrite];
    NSLog(@"downloaded %@", percent);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    // unused in this example
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSError* moveError;
    if (![[NSFileManager defaultManager] removeItemAtPath:self.selectedAsset.targetFile error:&moveError]) {
//        NSLog(@"Delete error: %@", moveError);
    }
    
    if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.selectedAsset.targetFile error:&moveError]) {
        NSLog(@"Move error: %@", moveError);
        return;
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"completed; error: %@", error);
    if (error) {
        _downloadButton.backgroundColor = [UIColor redColor];
    } else {
        _downloadButton.backgroundColor = [UIColor whiteColor];
    }
}


@end