//
//  PlayerViewController.m
//  KalturaDownloadSample
//
//  Created by Vitaliy Rusinov on 8/18/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "PlayerViewController.h"

static NSString * const kPlayerViewControllerServer = @"http://cdnapi.kaltura.com";

@interface PlayerViewController () <KPSourceURLProvider, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) KPPlayerConfig *config;
@property (nonatomic, strong) KPViewController *playerViewController;

@property (nonatomic, strong) MediaPlainObject *plain;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation PlayerViewController

#pragma mark - Actions

- (IBAction)didClickBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)didClickDownload:(id)sender {
    
    _downloadButton.enabled = NO;
    [self p_startDownload];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _downloadButton.enabled = ![self p_downloaded];
    
    self.config = [self p_configureWithLocalName: _plain.name
                                         entryId: _plain.entryId
                                        uiconfId: _plain.uiconfId
                                       partnerId: _plain.partnerId
                                  downloadEnable: YES];
    
    self.playerViewController = [self p_playerWithConfigure: _config];
    [self p_addKalturaPlayerAsSubview];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [self.playerViewController removePlayer];
    [self.playerViewController removeFromParentViewController];
    [self.playerViewController.view removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController.navigationBar setHidden: YES];
}

- (void)shouldUpdateCurrentModuleWithMediaPlainObject:(MediaPlainObject *)plain {
    
    self.plain = plain;
}

- (IBAction)didClickBackButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - KPViewController Moderator

- (KPViewController *) p_playerWithConfigure: (KPPlayerConfig *)config  {
    
    KPViewController *player = [[KPViewController alloc] initWithConfiguration:_config];
    player.customSourceURLProvider = self;
    
    return player;
}

- (void) p_addKalturaPlayerAsSubview {
    
    self.playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_playerViewController loadPlayerIntoViewController:self];
    
    [self addChildViewController: _playerViewController];
    [self.view addSubview: _playerViewController.view];
    
    [self.view bringSubviewToFront: _downloadButton];
    [self.view bringSubviewToFront: _backButton];
    
}


#pragma mark - Configure Moderator

- (KPPlayerConfig *) p_configureWithLocalName: (NSString *)localeName
                                      entryId: (NSString *)entryId
                                     uiconfId: (NSString *)uiconfId
                                    partnerId: (NSString *)partnerId
                               downloadEnable: (BOOL) downloadEnable {
    
    KPPlayerConfig *conf = [[KPPlayerConfig alloc] initWithServer: kPlayerViewControllerServer
                                                uiConfID: uiconfId 
                                               partnerId: partnerId];
    
    conf.cacheSize = 100;
    
    if (entryId.length > 0) {
        conf.entryId = entryId;
    }
    
    if (localeName.length > 0) {
        conf.localContentId = localeName;
    }

    return conf;
}

#pragma mark - Download Moderator 

- (BOOL) p_downloaded {
    
    NSString *target = [self p_targetFileWithMediaPlainObject: _plain];
    BOOL downloaded = NO;
    if (target.length > 0) {
        
        downloaded = [[NSFileManager defaultManager] fileExistsAtPath:target];
    }
    
    return downloaded;
}

- (NSString *) p_playbackUrl {
    
    NSString *target = [self p_targetFileWithMediaPlainObject: _plain];
    
    if ([self p_downloaded]) {
        
        return [NSURL fileURLWithPath: target].absoluteString;
    } else {
        
        return [self p_downloaded] ? target : nil;
    }
}

- (NSString *) p_downloadUrlWithMediaPlainObject: (MediaPlainObject *)plain {
    
    //https
    NSString *downloadLink = [NSString stringWithFormat:@"https://cdnapisec.kaltura.com/p/%@/sp/%@00/playManifest/entryId/%@/flavorId/%@/format/url/protocol/https/a.%@", plain.partnerId, plain.partnerId, plain.entryId, plain.flavorId, plain.format];
    
    //http
    downloadLink = [NSString stringWithFormat:@"http://cdnapi.kaltura.com/p/%@/sp/%@00/playManifest/entryId/%@/flavorId/%@/format/url/protocol/https/a.%@", plain.partnerId, plain.partnerId, plain.entryId, plain.flavorId, plain.format];
    
    return downloadLink;
}

- (NSString *) p_targetFileWithMediaPlainObject: (MediaPlainObject *)plain {
    
    NSString *target = @"";
    if (plain.name.length > 0) {
        
        NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        target = [documentDirectory stringByAppendingPathComponent: plain.name];
    }
    
    return target;
}

#pragma mark -

- (void) p_startDownload {
    
    NSURLSession *session = [self p_configureSession];
    NSString *downloadUrl = [self p_downloadUrlWithMediaPlainObject: _plain];
    NSLog(@"Download url: %@", downloadUrl);
    if (downloadUrl.length > 0) {
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL: [NSURL URLWithString: downloadUrl]];
        [task resume];
    }
}

- (NSURLSession *) p_configureSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    return session;
}

- (void) p_registerMediaWithConfig: (KPPlayerConfig *)config 
                           favorId: (NSString *)favorId 
                        targetFile: (NSString *)targetFile {
    
    [KPLocalAssetsManager registerAsset:config 
                                 flavor:favorId 
                                   path:targetFile 
                               callback:^(NSError *error) {
        
                                   NSLog(@"Done:%@", error);
                               }];
}

#pragma mark - KPSourceURLProvider

- (NSString *)urlForEntryId:(NSString *)entryId 
                 currentURL:(NSString *)current {
    
    return [self p_playbackUrl];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *percent = [NSString stringWithFormat:@"%lld%%", 100 * totalBytesWritten/totalBytesExpectedToWrite];
    NSLog(@"downloaded %@", percent);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *target = [self p_targetFileWithMediaPlainObject: _plain];
    if (target.length > 0) {
        
        NSError *moveError;
        if (![[NSFileManager defaultManager] removeItemAtPath: target error: &moveError]) {
            
            NSLog(@"Delete error: %@", moveError);
        }
        
        if (![[NSFileManager defaultManager] moveItemAtPath: location.path toPath: target error: &moveError]) {

            NSLog(@"Move error: %@", moveError);
            return;
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (!error) {
        NSString *target = [self p_targetFileWithMediaPlainObject: _plain];
        
        BOOL validParams = target.length > 0 && _config && _plain.flavorId.length > 0;
        if (validParams) {
            
            [self p_registerMediaWithConfig: _config
                                    favorId: _plain.flavorId
                                 targetFile: target];
        }
    } else {
        
        NSLog(@"completed; error: %@", error);
    }
}


@end
