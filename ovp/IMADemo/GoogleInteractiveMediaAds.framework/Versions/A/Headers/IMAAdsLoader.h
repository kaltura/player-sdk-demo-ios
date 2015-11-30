//
//  IMAAdsLoader.h
//  GoogleIMA3
//
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Declares a set of classes used when loading ads.

#import <Foundation/Foundation.h>

@class IMAAdError;
@class IMAAdsLoader;
@class IMAAdsManager;
@class IMAAdsRequest;
@class IMASettings;

#pragma mark - IMAAdsLoadedData

/// Ad loaded data that is returned when the ads loader loads the ad.
@interface IMAAdsLoadedData : NSObject

/// The ads manager instance created by the ads loader.
@property(nonatomic, strong, readonly) IMAAdsManager *adsManager;

/// The user context specified in the ads request.
@property(nonatomic, strong, readonly) id userContext;

@end

#pragma mark - IMAAdLoadingErrorData

/// Ad error data that is returned when the ads loader fails to load the ad.
@interface IMAAdLoadingErrorData : NSObject

/// The ad error that occured while loading the ad.
@property(nonatomic, strong, readonly) IMAAdError *adError;

/// The user context specified in the ads request.
@property(nonatomic, strong, readonly) id userContext;

@end

#pragma mark - IMAAdsLoaderDelegate

/// Delegate object that receives state change callbacks from IMAAdsLoader.
@protocol IMAAdsLoaderDelegate

/// Called when ads are successfully loaded from the ad servers by the loader.
- (void)adsLoader:(IMAAdsLoader *)loader
    adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData;

/// Error reported by the ads loader when ads loading failed.
- (void)adsLoader:(IMAAdsLoader *)loader
    failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData;

@end

#pragma mark - IMAAdsLoader

/// The IMAAdsLoader class allows the requesting of ads from the ad server.
/// Use the delegate to receive the loaded ads or loading error
/// in case of failure.
@interface IMAAdsLoader : NSObject

/// SDK-wide settings. Note that certain settings will only be evaluated
/// during initialization of the adsLoader.
@property(nonatomic, copy, readonly) IMASettings *settings;

/// Delegate that receives the result of the ad request.
@property(nonatomic, weak) id<IMAAdsLoaderDelegate> delegate;

/// Returns the SDK version.
+ (NSString *)sdkVersion;

/// Initializes the adsLoader with SDK wide |settings|. Uses default
/// settings if |settings| is nil.
- (instancetype)initWithSettings:(IMASettings *)settings;

/// Initializes the adsLoader with default settings.
- (instancetype)init;

/// Request ads from the ad server.
- (void)requestAdsWithRequest:(IMAAdsRequest *)request;

/// Signal to the SDK that the content has completed. The SDK will play
/// post-rolls at this time, if any are scheduled.
- (void)contentComplete;

@end
