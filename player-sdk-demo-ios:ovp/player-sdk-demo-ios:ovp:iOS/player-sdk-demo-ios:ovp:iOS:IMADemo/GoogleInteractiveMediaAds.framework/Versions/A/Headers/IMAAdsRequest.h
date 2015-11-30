//
//  IMAAdsRequest.h
//  GoogleIMA3
//
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Declares a simple ad request class.

#import <Foundation/Foundation.h>

@class IMAAdDisplayContainer;

/// Data class describing the ad request.
@interface IMAAdsRequest : NSObject

/// The ad request URL set.
@property(nonatomic, copy, readonly) NSString *adTagUrl;

/// The ad display containter.
@property(nonatomic, strong, readonly) IMAAdDisplayContainer *adDisplayContainer;

/// The user context.
@property(nonatomic, strong, readonly) id userContext;

/// Specifies whether the player intends to start the content and ad in
/// response to a user action or whether they will be automatically played.
/// Changing this setting will have no impact on ad playback.
@property(nonatomic) BOOL adWillAutoPlay;

/// Initializes an ads request instance with the |adTagUrl| and
/// |adDisplayContainer| specified.
- (instancetype)initWithAdTagUrl:(NSString *)adTagUrl
              adDisplayContainer:(IMAAdDisplayContainer *)adDisplayContainer
                     userContext:(id)userContext;

- (instancetype)init NS_UNAVAILABLE;

@end
