//
//  KalturaPlayerViewController.h
//  KalturaPlayerSample
//
//  Created by Vitaliy Rusinov on 7/6/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KALTURAPlayerSDK/KPViewController.h>
#import <KalturaPlayerSDK/KPLocalAssetsManager.h>
#import "Asset.h"

typedef NS_ENUM(NSInteger, KalturaPlayerState) {
    kKalturaPlayerStateReady = 0,
    kKalturaPlayerStatePlaying,
    kKalturaPlayerStatePaused
};

@class KalturaPlayerViewController;

typedef void (^PrepareConfigBlock)(KPPlayerConfig *config);

@protocol KalturaPlayerViewControllerDelegate <NSObject>

@optional

//MARK: Playback

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController mediaErrorWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerErrorWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController mediaLoadedWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPlayedWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPausedWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerStateDidChange: (KalturaPlayerState)state;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController playerPlayEndWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController preSeekWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController seekedWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController timeupdateWithCurrentTime: (NSNumber *) time;

//MARK: Ad

- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdSkipWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdPlayWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController onAdCompleteWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController AdSupport_EndAdPlaybackWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController AdSupport_StartAdPlaybackWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController postSequenceStartWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController postSequenceCompleteWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController preSequenceCompleteWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController preSequenceStartWithParams: (NSString *)params;
- (void) kalturaPlayerViewController: (KalturaPlayerViewController *)viewController adClickWithParams: (NSString *)params;

@end

@interface KalturaPlayerViewController : UIViewController

+ (KalturaPlayerViewController *) kalturaPlayer;

- (void) reloadConfigureWithUiConfId: (NSString *)uiConfId
                           partnerId: (NSString *)partnerId
                             entryId: (NSString *)entryId
                            delegate: (id<KalturaPlayerViewControllerDelegate>) delegate
                    prepareConfBlock: (PrepareConfigBlock) prepareConfBlock;

- (void) reloadConfigureWithName: (NSString *)name
                        uiConfId: (NSString *)uiConfId
                       partnerId: (NSString *)partnerId
                           entry: (NSString *)entryId
                          flavor: (NSString *)flavorId
                   offlineEnable: (BOOL)offline
                        delegate: (id<KalturaPlayerViewControllerDelegate>)delegate;

- (void) removePlayer;
- (void) replay;
- (void) play;
- (void) pause;
- (void) seekWithPlaybackTime: (NSTimeInterval)playbackTime;
- (NSTimeInterval) duration;
- (NSTimeInterval) currentPlaybackTime;

- (void) initializeCastProvider: (KCastProvider *)provider;

@end