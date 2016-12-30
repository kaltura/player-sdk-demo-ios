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
#import "Asset.h"

#import <DownloadToGo/DownloadToGo.h>
@import DownloadToGo;

typedef void (^callBackForPrepareToDownload)(KADownloadItem *);

static NSArray<Asset*>* demoAssets() {
    
    // TODO: modify the array of assets. 
    // Assets that are not meant to be downloaded can have nil as the flavor and url.
    return @[
        [Asset assetWithName:@"kalturaVideoSolutions" entry:@"0_00qaakql" flavor:@"0_gempayqv" url:@"https://cdnapisec.kaltura.com/p/2066791/sp/206679100/playManifest/entryId/0_00qaakql/flavorIds/0_gempayqv,0_1w1ijvw6/format/applehttp/protocol/https/a.m3u8"]
    ];
}

static KPPlayerConfig* configForDemoAsset(Asset* asset, BOOL forRegister) {
    // TODO: set server, uiconfid, partnerId
    KPPlayerConfig* config;
    config = [KPPlayerConfig configWithServer:@"https://cdnapisec.kaltura.com/html5/html5lib/v2.51/mwEmbedFrame.php" uiConfID:@"37289212" partnerId:@"2066791"];
    
    [config addConfigKey:@"closedCaptions.showEmbeddedCaptions" withValue:@"true"];
    [config addConfigKey:@"audioSelector.plugin" withValue:@"true"];
    
    // TODO (optional): set cachesize in MB
    config.cacheSize = 100; 
    
    // Common
    config.entryId = asset.entryId;
    config.localContentId = (asset.downloaded || forRegister) ? asset.localName : nil;
    
    return config;

}

@interface ViewController () <KADownloadItemDelegate, KPViewControllerDelegate, KPSourceURLProvider>
@property (nonatomic) KPViewController* kpv;
@property (strong, nonatomic) DownPicker* picker;
@property (nonatomic, readonly) Asset* selectedAsset;
@property (nonatomic) NSArray<Asset*>* assets;
@property (nonatomic) KPAssetRegistrationHelper* assetRegistrationHelper;
@property (strong, nonatomic) KADownloadItem *downloadItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _assets = demoAssets();
    
    [self prepareForDownloadWithMediaEntry:self.selectedAsset completion:^(KADownloadItem * downloadItem) {
        self.downloadItem = downloadItem;
        switch (downloadItem.downloadState) {
            case KADownloadItemDownloadStateInitial:
            case KADownloadItemDownloadStateInProgress:
            case KADownloadItemDownloadStatePaused:
            break;
            
            case KADownloadItemDownloadStateDownloaded:
            
            
            [self.playButton setBackgroundColor: [UIColor redColor]];
            break;
            
            default:
            break;
        }
    }];
    
    [self setDownPicker];
}
    
#pragma mark - Picker
    
- (void)setDownPicker {
    NSInteger selectedIndex = _picker ? _picker.selectedIndex : 0;
    
    _picker = [[DownPicker alloc] initWithTextField:_assetPicker withData:[_assets valueForKey:@"description"]];
    [_picker addTarget:self action:@selector(assetSelected:) forControlEvents:UIControlEventValueChanged];
    _picker.selectedIndex = selectedIndex;
}

- (Asset *)selectedAsset {
    return _assets[_picker.selectedIndex];
}
   
#pragma mark - Offline mode
    
- (void)startDownload {
    
    [_downloadItem addDelegate: self];
    
    [_downloadItem loadInfo:^(KADownloadItem * _Nonnull item, BOOL success) {
        
        if (success) {
            
            [item selectVideoStreams:@[@0] completion:^(BOOL success) {
               
                if (success) {
                    
                    [item selectAudioStreams:@[@0,@1] completion:^(BOOL success) {
                        
                        if (success) {
                            
                            [item startDownload];
                        }
                    }];
                }
            }];
        }
    }];
}
    
- (void)prepareForDownloadWithMediaEntry:(Asset *)mediaEntry completion: (callBackForPrepareToDownload)callBack {
    
    NSString *sourceUrl = mediaEntry.downloadUrl;
    NSString *sourceFormat = @"m3u8";
    
    [[KADownloadManager sharedInstance] getItem: mediaEntry.entryId itemUrl: sourceUrl itemFormat: sourceFormat completion:^(KADownloadItem * _Nonnull item) {
        
        if (callBack) {
        
            callBack(item);
        }
    }];
}
    
#pragma mark - KADownloadItemDelegate
    
- (void)downloadWillStart:(KADownloadItem * _Nonnull)item {
    
}
    
- (void)downloadStarted:(KADownloadItem * _Nonnull)item {
    
}
    
- (void)downloadPaused:(KADownloadItem * _Nonnull)item {
    
}
    
- (void)downloadInterrupted:(KADownloadItem * _Nonnull)item {
    
}
    
- (void)downloadFailed:(KADownloadItem * _Nonnull)item error:(NSError * _Nullable)error {
    
}
    
- (void)downloadResumed:(KADownloadItem * _Nonnull)item {
    
}
    
- (void)downloadFinished:(KADownloadItem * _Nonnull)item {
    
    NSLog(@"downloadFinished: %@", item.playUrl);
    
    _downloadButton.backgroundColor = [UIColor yellowColor];
}
    
- (void)downloadInProgress:(KADownloadItem * _Nonnull)item {
    
    NSLog(@"downloadInProgress: %f", item.currentProgress);
}
    
#pragma mark - KPViewControllerDelegate, KPSourceURLProvider
    
-(NSString*)urlForEntryId:(NSString *)entryId currentURL:(NSString *)current {
    
    NSString *playUrl = nil;
    if (_downloadItem.downloadState == KADownloadItemDownloadStateDownloaded) {
        
        playUrl = _downloadItem.playUrl.absoluteString;
    }
    return playUrl;
}
    
#pragma mark - Actions
    
- (IBAction)assetSelected:(id)sender {

}
    
- (IBAction)playTapped:(UIButton*)button {
    
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
    
- (IBAction)loadTapped:(UIButton*)button {
    
    [self startDownload];
}

@end

@implementation ViewController (KalturaPlayer)




@end
