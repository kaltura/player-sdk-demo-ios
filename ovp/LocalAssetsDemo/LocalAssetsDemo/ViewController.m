//
//  ViewController.m
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 18/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

// Note to users of this demo app: customize the demoAssets() and configForDemoAsset() functions.

#import "ViewController.h"

#import <KalturaPlayerSDK/KPLocalAssetsManager.h>
#import <KalturaPlayerSDK/KPViewController.h>
#import <DownPicker/DownPicker.h>


static NSArray<Asset*>* demoAssets() {
    
    // TODO: modify the array of assets. 
    // Assets that are not meant to be downloaded can have nil as the flavor and url.
    return @[
             [Asset assetWithName:@"sintel.wvm" entry:@"0_pl5lbfo0" flavor:@"1_e0qtaj1j" url:@"http://cdnapi.kaltura.com/p/1851571/sp/185157100/playManifest/entryId/0_pl5lbfo0/flavorId/1_e0qtaj1j/format/url/protocol/http/a.wvm"],
             [Asset assetWithName:@"count.wvm" entry:@"0_uafvpmv8" flavor:@"0_2rl0w6f1" url:@"http://cdnapi.kaltura.com/p/1851571/sp/185157100/playManifest/entryId/0_uafvpmv8/flavorId/0_2rl0w6f1/format/url/protocol/http/a.wvm"],
             [Asset assetWithName:@"cat.mp4" entry:@"1_aegxx56o" flavor:@"1_6dadj61z" url:@"http://cfvod.kaltura.com/pd/p/1851571/sp/185157100/serveFlavor/entryId/1_aegxx56o/v/11/flavorId/1_6dadj61z/name/a.mp4"],
             ];
}

static KPPlayerConfig* configForDemoAsset(Asset* asset) {
    // TODO: set server, uiconfid, partnerId
    KPPlayerConfig* config;
    config = [[KPPlayerConfig alloc] 
              initWithServer:@"https://cdnapisec.kaltura.com" 
              uiConfID:@"31956421" partnerId:@"1851571"];    
    
    // TODO (optional): set cachesize in MB
    config.cacheSize = 100; 
    
    // TODO (optional): set KS, if required
    //    config.ks = @"KS";
    
    // TODO (optional): customize the player some more. 
    // [config addConfigKey:<#(NSString *)#> withValue:<#(NSString *)#>];
    // [config addConfigKey:<#(NSString *)#> withDictionary:<#(NSDictionary *)#>];

    // TODO (optional): add extra cache inclusion patterns.
    config.cacheConfig.includePatterns = @[
                                        ];
    
    // Common
    config.entryId = asset.entryId;
    config.localContentId = asset.downloaded ? asset.localName : nil;
    
    return config;

}





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
    
    [KPLocalAssetsManager checkStatusForAsset:configForDemoAsset(self.selectedAsset) path:self.selectedAsset.targetFile callback:^(NSError *error, NSTimeInterval expiryTime, NSTimeInterval availableTime) {
        NSLog(@"status: %d -- %d -- error: %@", (int)expiryTime, (int)availableTime, error);
    }];
}

-(IBAction)playTapped:(UIButton*)button {
    
    if (!_kpv) {
        KPViewController* kpv = [[KPViewController alloc] initWithConfiguration:configForDemoAsset(self.selectedAsset)];
        [kpv setCustomSourceURLProvider:self];
        [kpv setDelegate:self];
        
        kpv.view.frame = _playerContainer.bounds;
        [self addChildViewController:kpv];
        [_playerContainer addSubview:kpv.view];
        
        _kpv = kpv;
    } else {
        [_kpv resetPlayer];
        [_kpv changeConfiguration:configForDemoAsset(self.selectedAsset)];
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
    
    [KPLocalAssetsManager registerAsset:configForDemoAsset(self.selectedAsset) flavor:self.selectedAsset.flavorId path:self.selectedAsset.targetFile callback:^(NSError *error) {
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
    
    [self setDownPicker];
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
