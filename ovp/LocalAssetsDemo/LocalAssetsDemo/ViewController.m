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

#import "AVAssetDownloader.h"

static NSArray<Asset*>* demoAssets() {
    
    // TODO: modify the array of assets. 
    // Assets that are not meant to be downloaded can have nil as the flavor and url.
    return @[
//               [Asset assetWithName:@"kalturaVideoSolutions" entry:@"0_00qaakql" flavor:@"0_gempayqv" url:@"https://cdnapisec.kaltura.com/p/2066791/sp/206679100/playManifest/entryId/0_00qaakql/flavorIds/0_gempayqv,0_1w1ijvw6/format/applehttp/protocol/https/a.m3u8"]
//             [Asset assetWithName:@"kalturaVideoSolutions" entry:@"1_nzffqkbk" flavor:@"1_tebzcakx" url:@"https://cdnapisec.kaltura.com/p/2215841/sp/221584100/playManifest/entryId/1_nzffqkbk/flavorIds/1_fwqw0ess,1_yq43k0hz,1_7pjl2kat,1_tebzcakx/format/applehttp/protocol/https/a.m3u8"],
//             [Asset assetWithName:@"kalturaVideoSolutions" entry:@"0_00qaakql" flavor:@"0_gempayqv" url:@"https://cdnapisec.kaltura.com/p/2066791/sp/206679100/playManifest/entryId/0_00qaakql/flavorIds/0_gempayqv,0_1w1ijvw6/format/applehttp/protocol/https/a.m3u8"]
             [Asset assetWithName:@"kalturaVideoSolutions" entry:@"1_asj9g38z" flavor:@"1_qorlzr41" url:@"https://cdnapisec.kaltura.com/p/2066791/sp/206679100/playManifest/entryId/1_asj9g38z/flavorIds/1_qorlzr41,1_63qjt3w3/format/applehttp/protocol/https/a.m3u8"]
            ];
}

static KPPlayerConfig* configForDemoAsset(Asset* asset, BOOL forRegister) {
    // TODO: set server, uiconfid, partnerId
    KPPlayerConfig* config;
    config = [KPPlayerConfig configWithServer:@"https://cdnapisec.kaltura.com/html5/html5lib/v2.51/mwEmbedFrame.php" uiConfID:@"37747041" partnerId:@"2215841"];
//    config = [KPPlayerConfig configWithServer:@"https://cdnapisec.kaltura.com/html5/html5lib/v2.51/mwEmbedFrame.php" uiConfID:@"37289212" partnerId:@"2066791"];
    [config addConfigKey:@"closedCaptions.showEmbeddedCaptions" withValue:@"true"];
    [config addConfigKey:@"audioSelector.plugin" withValue:@"true"];
    
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

- (void)startDownload {
    
    kDownloadProgressReport progressReport = ^(float progress) {
        NSLog(@"progress: %f", progress);
        
        if (progress == 2) {
            _downloadButton.backgroundColor = [UIColor whiteColor];
            _downloadButton.titleLabel.text = @"Download";
            [self setDownPicker];
        } else if (progress == -1) {
            _downloadButton.backgroundColor = [UIColor redColor];
        }
    };
    
    KPPlayerConfig* playerConfig = configForDemoAsset(self.selectedAsset, YES);
    AssetDownloader* downloader = [AssetDownloader downloaderForAsset:self.selectedAsset config:playerConfig];
    
    downloader.progressReport = progressReport;
    [downloader startDownload];
    
    _downloadButton.backgroundColor = [UIColor yellowColor];
}

@end

@implementation ViewController (KalturaPlayer)

-(NSString*)urlForEntryId:(NSString *)entryId currentURL:(NSString *)current {
    
    NSAssert([entryId isEqualToString:self.selectedAsset.entryId], @"Demo: assuming we're playing the selected asset");
    
    return self.selectedAsset.playbackUrl;
}


@end
