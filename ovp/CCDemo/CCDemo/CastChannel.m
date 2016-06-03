//
//  CastChannel.m
//  CCDemo
//
//  Created by Nissim Pardo on 03/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "CastChannel.h"

@implementation CastChannel
- (void)didReceiveTextMessage:(NSString *)message {
    if ([_delegate respondsToSelector:@selector(didReceiveTextMessage:)]) {
        [_delegate didReceiveTextMessage:message];
    }
}
@end
