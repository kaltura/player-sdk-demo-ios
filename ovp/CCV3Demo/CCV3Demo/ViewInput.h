//
//  ViewControllerInput.h
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kShowViewController = @"ShowViewController";

@protocol ViewInput <NSObject>
- (void) shouldUpdateWithEntryId: (NSString *) entryId;
@end
