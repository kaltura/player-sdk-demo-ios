//
//  KalturaPlayerViewController.m
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/6/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "KalturaPlayerViewController.h"
@import GoogleInteractiveMediaAds;

//static NSString * const kServer = @"http://10.0.20.26/html5.kaltura/mwEmbed/mwEmbedFrame.php";
static NSString * const kServer = @"http://cdnapi.kaltura.com";

static NSString * const kKalturaPlayerViewControllerEvent_MediaError = @"mediaError";
static NSString * const kKalturaPlayerViewControllerEvent_PlayerError = @"playerError";
static NSString * const kKalturaPlayerViewControllerEvent_MediaLoaded = @"mediaLoaded";
static NSString * const kKalturaPlayerViewControllerEvent_PlayerPlayed = @"playerPlayed";
static NSString * const kKalturaPlayerViewControllerEvent_PlayerPaused = @"playerPaused";
static NSString * const kKalturaPlayerViewControllerEvent_PlayerStateChange = @"playerStateChange";
static NSString * const kKalturaPlayerViewControllerEvent_PlayerPlayEnd = @"playerPlayEnd";
static NSString * const kKalturaPlayerViewControllerEvent_PreSeek = @"preSeek";
static NSString * const kKalturaPlayerViewControllerEvent_Seeked = @"seeked";
static NSString * const kKalturaPlayerViewControllerEvent_Timeupdate = @"timeupdate";
static NSString * const kKalturaPlayerViewControllerEvent_PostSequenceStart = @"postSequenceStart";
static NSString * const kKalturaPlayerViewControllerEvent_PostSequenceComplete = @"postSequenceComplete";
static NSString * const kKalturaPlayerViewControllerEvent_PreSequenceComplete = @"preSequenceComplete";
static NSString * const kKalturaPlayerViewControllerEvent_PreSequenceStart = @"preSequenceStart";
static NSString * const kKalturaPlayerViewControllerEvent_OnAdPlay = @"onAdPlay";
static NSString * const kKalturaPlayerViewControllerEvent_OnAdComplete = @"onAdComplete";
static NSString * const kKalturaPlayerViewControllerEvent_AdSupport_EndAdPlayback = @"AdSupport_EndAdPlayback";
static NSString * const kKalturaPlayerViewControllerEvent_AdSupport_StartAdPlayback = @"AdSupport_StartAdPlayback";
static NSString * const kKalturaPlayerViewControllerEvent_onAdSkip = @"onAdSkip";
static NSString * const kKalturaPlayerViewControllerEvent_adClick = @"adClick";

@interface KalturaPlayerViewController () <NSURLSessionDelegate, KPSourceURLProvider, KPViewControllerDelegate>

@property (nonatomic, weak) id<KalturaPlayerViewControllerDelegate> delegate;

@property (nonatomic, strong) KPPlayerConfig *config;
@property (nonatomic, strong) KPViewController *playerViewController;

@property (nonatomic, strong) NSString *uiConfiguratorId;
@property (nonatomic, strong) NSString *partnerId;
@property (nonatomic, strong) NSString *entryId;
@property (nonatomic, strong) NSString *localContentId;
@property (nonatomic, strong) NSString *flavorId;

@property (nonatomic, strong) Asset *localAsset;

@property (nonatomic, strong) PrepareConfigBlock prepareConfBlock;

@end

@implementation KalturaPlayerViewController

#pragma mark - Life cycle

+ (KalturaPlayerViewController *)kalturaPlayer {
    
    return [[KalturaPlayerViewController alloc] init];
}

#pragma mark - Public methods

- (void)reloadConfigureWithUiConfId:(NSString *)uiConfId 
                          partnerId:(NSString *)partnerId 
                            entryId:(NSString *)entryId 
                           delegate:(id<KalturaPlayerViewControllerDelegate>)delegate 
                   prepareConfBlock:(PrepareConfigBlock)prepareConfBlock {
    
    self.delegate = delegate;
    
    self.uiConfiguratorId = uiConfId;
    self.partnerId = partnerId;
    self.entryId = entryId;
    self.prepareConfBlock = prepareConfBlock;
    self.localContentId = nil;
    
    [self p_configModerator];
    [self p_playerModerator];
}

- (void)reloadConfigureWithName: (NSString *)name
                       uiConfId: (NSString *)uiConfId
                      partnerId: (NSString *)partnerId
                          entry: (NSString *)entryId
                         flavor: (NSString *)flavorId
                  offlineEnable: (BOOL) offline
                       delegate: (id<KalturaPlayerViewControllerDelegate>)delegate {
    
    self.localAsset = [Asset assetWithName: name
                                     entry: entryId
                                    flavor: flavorId
                                       url: [NSString stringWithFormat:@"http://cfvod.kaltura.com/pd/p/%@/sp/%@00/serveFlavor/entryId/%@/v/11/flavorId/%@/name/a.mp4", partnerId, partnerId, entryId, flavorId]];
    
    [_playerViewController setDelegate: self];
    
    self.delegate = delegate;
    self.entryId = entryId;
    self.partnerId = partnerId;
    self.flavorId = flavorId;
    self.uiConfiguratorId = uiConfId;
    
    self.config = [self p_configureWithAsset:self.localAsset 
                               offlineEnable:YES];
    [self p_playerModerator];
    
    if (!self.localAsset.downloaded) {
        
        [self p_startDownload];
    }
}

#pragma mark - Actions

- (void) removePlayer {
    
    if (_playerViewController != nil) {
        
        [_playerViewController removePlayer];
    }
}

- (void) replay {
    
    if (_playerViewController != nil) {
        
        [_playerViewController.playerController replay];
    }
}

- (void) play {
    
    if (_playerViewController != nil) {
        
        [_playerViewController.playerController play];
    }
}

- (void) pause {
    
    if (_playerViewController != nil) {
        
        [_playerViewController.playerController pause];
    }
}

- (void) seekWithPlaybackTime: (NSTimeInterval) playbackTime {
    
    if (_playerViewController != nil) {
        
        [_playerViewController.playerController seek: playbackTime];
    }
}

- (NSTimeInterval) duration {
    
    return [_playerViewController.playerController duration];
}

- (NSTimeInterval) currentPlaybackTime {
    
    return [_playerViewController.playerController currentPlaybackTime];
}

#pragma mark - Private methods

- (KPPlayerConfig *) p_configureWithAsset:(Asset *)asset offlineEnable: (BOOL) offline {
    
    KPPlayerConfig* config;
    config = [[KPPlayerConfig alloc]
              initWithServer:@"http://cdnapi.kaltura.com"
              uiConfID:_uiConfiguratorId partnerId:_partnerId];
    
    config.cacheSize = offline ? 100 : 0.8;
    config.entryId = asset.entryId;
    config.localContentId = asset.localName;
    
    return config;
}

- (void) p_addAsSubviewKalturaPlayer {
    
    self.playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_playerViewController loadPlayerIntoViewController:self];
    
    [self.view addSubview:_playerViewController.view];
}

- (void) p_configModerator {
    
    self.config = [[KPPlayerConfig alloc] initWithServer: kServer
                                                uiConfID: _uiConfiguratorId
                                               partnerId: _partnerId];
    // Video Entry
    _config.entryId = _entryId;
    _config.localContentId = self.localContentId;
    
    if (_prepareConfBlock != nil) {
        
        _prepareConfBlock(_config);
        self.prepareConfBlock = nil;
    }
}

- (void) p_playerModerator {
    
    if (_playerViewController == nil) {
        
        self.playerViewController = [[KPViewController alloc] initWithConfiguration:_config];
        
        self.playerViewController.customSourceURLProvider = self;
        
        [self p_addAsSubviewKalturaPlayer];
        [self p_eventsModertor];
    } else {
        
        /*
         
         To change the configuration, load a new configuration object to the old Player instance as following:
         Remember to use this ONLY if you used resetPlayer previously.
         
         */
        
        [_playerViewController resetPlayer];
        [_playerViewController changeConfiguration:_config];
    }
}

- (void) p_eventsModertor {
    
    if (_playerViewController != nil) {
        
        [self removeEventListener];
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:mediaErrorWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_MediaError eventID:@"mediaError1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf mediaErrorWithParams:params];
            }];
        }
       
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerErrorWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerError eventID:@"playerError1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf playerErrorWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:mediaLoadedWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_MediaLoaded eventID:@"mediaLoaded1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf mediaLoadedWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPlayedWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPlayed eventID:@"playerPlayed1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf playerPlayedWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPausedWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPaused eventID:@"playerPaused1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf playerPausedWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerStateDidChange:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerStateChange eventID:@"playerStateChange1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                KalturaPlayerState state = kKalturaPlayerStateReady;
                if ([params isEqualToString:@"ready"]) {
                    
                    state = kKalturaPlayerStateReady;
                }
                
                [strongSelf.delegate kalturaPlayerViewController: strongSelf 
                                            playerStateDidChange: state];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPlayEndWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPlayEnd eventID:@"playerPlayEnd1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf playerPlayEndWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSeekWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSeek eventID:@"preSeek1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf preSeekWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:seekedWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_Seeked eventID:@"seeked1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf seekedWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:timeupdateWithCurrentTime:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_Timeupdate eventID:@"timeupdate1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                NSNumber *currentTime = [strongSelf p_serializeParamsForTimeupdateWithString:params];
                if (currentTime != nil) {
                    
                    [strongSelf.delegate kalturaPlayerViewController: strongSelf timeupdateWithCurrentTime: currentTime];
                }
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:postSequenceStartWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PostSequenceStart eventID:@"postSequenceStart1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf postSequenceStartWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:postSequenceCompleteWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PostSequenceComplete eventID:@"postSequenceComplete1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf postSequenceCompleteWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSequenceStartWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSequenceStart eventID:@"preSequenceStart1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf preSequenceStartWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSequenceCompleteWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSequenceComplete eventID:@"preSequenceComplete1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController: strongSelf preSequenceCompleteWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdPlayWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_OnAdPlay eventID:@"kOnAdPlay1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf onAdPlayWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdCompleteWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_OnAdComplete eventID:@"onAdComplete1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf onAdCompleteWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:AdSupport_EndAdPlaybackWithParams:)]) {
        
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_AdSupport_EndAdPlayback eventID:@"AdSupport_EndAdPlayback1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf AdSupport_EndAdPlaybackWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:AdSupport_StartAdPlaybackWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_AdSupport_StartAdPlayback eventID:@"AdSupport_StartAdPlayback1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf AdSupport_StartAdPlaybackWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdSkipWithParams:)]) {
#warning Skip event doesn't work!
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_onAdSkip eventID:@"onAdSkip1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf onAdSkipWithParams:params];
            }];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:adClickWithParams:)]) {
            
            typeof(self)  __weak weakSelf = self;
            [_playerViewController addKPlayerEventListener: kKalturaPlayerViewControllerEvent_adClick eventID:@"adClick1" handler:^(NSString *eventName, NSString *params) {
                
                typeof(self) __strong strongSelf = weakSelf;
                [strongSelf.delegate kalturaPlayerViewController:strongSelf adClickWithParams: params];
            }];
        }
    }
}

- (NSNumber *) p_serializeParamsForTimeupdateWithString: (NSString *)params {
    
    NSNumber *currentTime = @(0.0);
    NSError *jsonError = nil;
    NSData *jsonData = [params dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
        id time = [[jsonDictionary objectForKey:@"currentTarget"] objectForKey:@"currentTime"];
        if ([time isKindOfClass: [NSNumber class]]) {
            
            currentTime = (NSNumber *) time;
        }
    }

    return currentTime;
}

- (void) removeEventListener {
    
    if (_playerViewController != nil) {
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdPlayWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_OnAdPlay eventID:@"kOnAdPlay2"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:mediaErrorWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_MediaError eventID:@"mediaError1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerErrorWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerError eventID:@"playerError1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:mediaLoadedWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_MediaLoaded eventID:@"mediaLoaded1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPlayedWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPlayed eventID:@"playerPlayed1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPausedWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPaused eventID:@"playerPaused1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerStateDidChange:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerStateChange eventID:@"playerStateChange1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:playerPlayEndWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PlayerPlayEnd eventID:@"playerPlayEnd1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSeekWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSeek eventID:@"preSeek1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:seekedWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_Seeked eventID:@"seeked1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:timeupdateWithCurrentTime:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_Timeupdate eventID:@"timeupdate1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:postSequenceStartWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PostSequenceStart eventID:@"postSequenceStart1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:postSequenceCompleteWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PostSequenceComplete eventID:@"postSequenceComplete1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSequenceStartWithParams:)]) {
            
             [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSequenceStart eventID:@"preSequenceStart1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:preSequenceCompleteWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_PreSequenceComplete eventID:@"preSequenceComplete1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdCompleteWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_OnAdComplete eventID:@"onAdComplete1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:AdSupport_EndAdPlaybackWithParams:)]) {
            
             [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_AdSupport_EndAdPlayback eventID:@"AdSupport_EndAdPlayback1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:AdSupport_StartAdPlaybackWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_AdSupport_StartAdPlayback eventID:@"AdSupport_StartAdPlayback1"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:onAdSkipWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_onAdSkip eventID:@"onAdSkip"];
        }
        
        if ([self.delegate respondsToSelector:@selector(kalturaPlayerViewController:adClickWithParams:)]) {
            
            [_playerViewController removeKPlayerEventListener: kKalturaPlayerViewControllerEvent_adClick eventID:@"adClick1"];
        }
    }
}

- (void)initializeCustprovider:(KCastProvider *)provider {
    
    self.playerViewController.castProvider = provider;
}

#pragma mark - Download 

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
    
    if (!error) {
        
        [self p_registerAssetWithConfig:_config 
                                favorId:_flavorId 
                             targetFile:self.localAsset.targetFile];
    } else {
        
        NSLog(@"completed; error: %@", error);
    }
}

#pragma mark - KPSourceURLProvider

- (NSString *)urlForEntryId:(NSString *)entryId currentURL:(NSString*)current {
    
    return [_localAsset playbackUrl];
}

@end
