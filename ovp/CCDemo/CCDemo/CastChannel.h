//
//  CastChannel.h
//  CCDemo
//
//  Created by Nissim Pardo on 03/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>

@protocol CastChannelDelegate <NSObject>

- (void)didReceiveTextMessage:(NSString *)message;

@end

@interface CastChannel : GCKCastChannel
@property (nonatomic, weak) id<CastChannelDelegate> delegate;
@end
