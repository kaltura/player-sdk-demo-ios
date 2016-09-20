//
//  ViewController.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 18/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

// Note to users of this demo app: customize the demoAssets() and configForDemoAsset() functions.

#import "ViewController.h"

#import <KalturaPlayerSDK/KPAssetRegistrationHelper.h>
#import <KalturaPlayerSDK/KPLocalAssetsManager.h>
#import <KalturaPlayerSDK/KPViewController.h>
#import <DownPicker/DownPicker.h>


static NSArray<Asset*>* demoAssets() {
    
    // TODO: modify the array of assets. 
    // Assets that are not meant to be downloaded can have nil as the flavor and url.
    return @[
             [Asset assetWithName:@"sintel.fps" entry:@"0_pl5lbfo0" flavor:@"0_zwq3l44r"   url:@"https://cdnapisec.kaltura.com/p/1851571/playManifest/entryId/0_pl5lbfo0/flavorIds/0_zwq3l44r/format/applehttp/protocol/https/a.m3u8"],
             [Asset assetWithName:@"count.wvm" entry:@"0_uafvpmv8" flavor:@"0_2rl0w6f1" url:@"http://cdnapi.kaltura.com/p/1851571/sp/185157100/playManifest/entryId/0_uafvpmv8/flavorId/0_2rl0w6f1/format/url/protocol/http/a.wvm"],
             ];
}

static KPPlayerConfig* configForDemoAsset(Asset* asset, BOOL forRegister) {
    // TODO: set server, uiconfid, partnerId
    KPPlayerConfig* config;
    config = [KPPlayerConfig configWithServer:@"https://cdnapisec.kaltura.com" uiConfID:@"31956421" partnerId:@"1851571"];
    
    // TODO (optional): set cachesize in MB
    config.cacheSize = 100; 
    
    // TODO (optional): set KS, if required by server config
    //config.ks = @KS;
    
    // TODO (optional): customize the player some more. 
    // [config addConfigKey:(NSString *) withValue:(NSString *)];
    // [config addConfigKey:(NSString *) withDictionary:(NSDictionary *)];
    // [config addConfigKey:@"autoPlay" withValue:@"true"];

    // TODO (optional): add extra cache inclusion patterns (regexps)
    // config.cacheConfig.includePatterns = @[];
    
    // Common
    config.entryId = asset.entryId;
    config.localContentId = (asset.downloaded || forRegister) ? asset.localName : nil;
    
    return config;

}





@interface ViewController ()
@property (nonatomic) KPViewController* kpv;
@property (strong, nonatomic) DownPicker* picker;
@property (nonatomic, readonly) Asset* selectedAsset;
@property (nonatomic) NSArray<Asset*>* assets;

@property (nonatomic) KPAssetRegistrationHelper* assetRegistrationHelper;
@end

@interface ViewController (KalturaPlayer) <KPViewControllerDelegate, KPSourceURLProvider>
@end

@interface ViewController (Download) <NSURLSessionDownloadDelegate, AVAssetDownloadDelegate>
- (void)startDownload;
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


@implementation ViewController

-(void)setDownPicker {
    NSInteger selectedIndex = _picker ? _picker.selectedIndex : 0;
    
    _picker = [[DownPicker alloc] initWithTextField:_assetPicker withData:[_assets valueForKey:@"description"]];
    [_picker addTarget:self action:@selector(assetSelected:) forControlEvents:UIControlEventValueChanged];
    _picker.selectedIndex = selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _assets = demoAssets();
    
    [self setDownPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(Asset *)selectedAsset {
    return _assets[_picker.selectedIndex];
}

-(IBAction)assetSelected:(id)sender {
}

-(IBAction)statusTapped:(UIButton*)button {
    
    [KPLocalAssetsManager checkStatusForAsset:configForDemoAsset(self.selectedAsset, YES) path:self.selectedAsset.targetFile callback:^(NSError *error, NSTimeInterval expiryTime, NSTimeInterval availableTime) {
        NSLog(@"status: %d -- %d -- error: %@", (int)expiryTime, (int)availableTime, error);
    }];
}

-(IBAction)playTapped:(UIButton*)button {
    
    KPPlayerConfig* config = configForDemoAsset(self.selectedAsset, NO);
    if (!_kpv) {
        KPViewController* kpv = [[KPViewController alloc] initWithConfiguration:config];
        [kpv setCustomSourceURLProvider:self];
        [kpv setDelegate:self];
        
        kpv.view.frame = _playerContainer.bounds;
        [self addChildViewController:kpv];
        [_playerContainer addSubview:kpv.view];
        
        _kpv = kpv;
    } else {
        [_kpv resetPlayer];
        [_kpv changeConfiguration:config];
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
    
    NSString* path = self.selectedAsset.targetFile;

    [KPLocalAssetsManager registerAsset:configForDemoAsset(self.selectedAsset, YES) flavor:self.selectedAsset.flavorId path:path callback:^(NSError *error) {
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
    
    self.assetRegistrationHelper = [KPAssetRegistrationHelper helperForAsset:configForDemoAsset(self.selectedAsset, YES) flavor:self.selectedAsset.flavorId];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LocalAssetsDemo"];
    
    NSURL* downloadUrl = [NSURL URLWithString:self.selectedAsset.downloadUrl];
    if ([downloadUrl.pathExtension isEqualToString:@"m3u8"]) {
        NSError* error;
        AVURLAsset* urlAsset = [AVURLAsset assetWithURL:downloadUrl];
        [self.assetRegistrationHelper prepareAssetForDownload:urlAsset error:&error];
        
        AVAssetDownloadURLSession *session = [AVAssetDownloadURLSession sessionWithConfiguration:config assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
        AVAssetDownloadTask* task = [session assetDownloadTaskWithURLAsset:urlAsset assetTitle:self.selectedAsset.localName assetArtworkData:nil options:nil];
        task.taskDescription = self.selectedAsset.localName;
        
        [task resume];
    } else {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDownloadTask* task = [session downloadTaskWithURL:downloadUrl];
        [task resume];
    }
        
    _downloadButton.backgroundColor = [UIColor yellowColor];
}


// AVAsset download
-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {
    
}

-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    [[NSUserDefaults standardUserDefaults] setObject:location.relativePath forKey:assetDownloadTask.taskDescription];
    [self setDownPicker];
}

-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    float fraction = (float)(timeRange.start.value+timeRange.duration.value) / timeRangeExpectedToLoad.duration.value;
    
    _downloadButton.titleLabel.text = [NSString stringWithFormat:@"%.1f", fraction*100];
    
    NSLog(@"didLoadTimeRange: %lld (%lld); expected:  %lld", 
          timeRange.start.value/timeRange.start.timescale, timeRange.duration.value/timeRange.duration.timescale,
          timeRangeExpectedToLoad.duration.value/timeRangeExpectedToLoad.duration.timescale);

}


// Regular download

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString* percent = [NSString stringWithFormat:@"%lld%%", 100*totalBytesWritten/totalBytesExpectedToWrite];
    NSLog(@"downloaded %@", percent);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    // unused in this example
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // Regular download -- now move to target path.
    
    NSError* moveError;
    if (![[NSFileManager defaultManager] removeItemAtPath:self.selectedAsset.targetFile error:&moveError]) {
        //        NSLog(@"Delete error: %@", moveError);
    }
    
    if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.selectedAsset.targetFile error:&moveError]) {
        NSLog(@"Move error: %@", moveError);
        return;
    }
    
    [self setDownPicker];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([task isKindOfClass:[AVAssetDownloadTask class]]) {
        AVAssetDownloadTask* assetDownloadTask = (AVAssetDownloadTask *)task;
        NSLog(@"asset %@ completed; error: %@", assetDownloadTask.URLAsset.URL, error);
    } else {
        NSLog(@"completed; error: %@", error);
    }

    if (error) {
        _downloadButton.backgroundColor = [UIColor redColor];
    } else {
        _assetRegistrationHelper.assetRegistrationBlock = ^(NSError* error) {
            // This is called when saveAssetAtPath completes
            NSLog(@"Done; error: %@", error);
        };
        [_assetRegistrationHelper saveAssetAtPath:self.selectedAsset.targetURL];
        _downloadButton.backgroundColor = [UIColor whiteColor];
    }
    
    _downloadButton.titleLabel.text = @"Download";    
}


@end
