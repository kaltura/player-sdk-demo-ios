//
//  IMACompanionAdSlot.h
//  GoogleIMA3
//
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Declares a data class that describes a companion ad slot.

#import <UIKit/UIKit.h>

@class IMACompanionAdSlot;

#pragma mark IMACompanionDelegate

/// Optional delegate to receive events from the companion ad slot.
@protocol IMACompanionDelegate<NSObject>

/// Called when the slot is either filled or not filled.
- (void)companionSlot:(IMACompanionAdSlot *)slot filled:(BOOL)filled;

@end

#pragma mark - IMACompanionAdSlot

/// Ad slot for companion ads. The SDK will put a subview inside the provided
/// UIView container. The companion will be matched to the width and height
/// provided here.
@interface IMACompanionAdSlot : NSObject

/// The view the companion will be rendered in. Display this view in your
/// application before video ad starts.
@property(nonatomic, strong, readonly) UIView *view;

/// Width of the slot, in pixels. This value is sent to the DFP ad server for
/// targeting.
@property(nonatomic, readonly) int width;

/// Height of the slot, in pixels. This value is sent to the DFP ad server for
/// targeting.
@property(nonatomic, readonly) int height;

/// Receive events from the companion ad slot.
@property(nonatomic, weak) id<IMACompanionDelegate> delegate;

- (instancetype)initWithView:(UIView *)view
                       width:(int)width
                      height:(int)height;

- (instancetype)init NS_UNAVAILABLE;

@end
