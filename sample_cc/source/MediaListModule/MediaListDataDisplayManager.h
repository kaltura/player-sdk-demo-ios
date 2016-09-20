//
//  CCDataDisplayManager.h
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlainObject.h"

@class MediaListDataDisplayManager;

@protocol MediaListDataDisplayManagerDelegate  <NSObject>

@optional
- (void) didUpdateForDataDisplayManager: (MediaListDataDisplayManager *)ddManager;
- (void) dataDisplayManager: (MediaListDataDisplayManager *)ddManager didSelectPlainObj:(MediaPlainObject *) plain;

@end

@interface MediaListDataDisplayManager : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<MediaListDataDisplayManagerDelegate> delegate;
- (void) updateTableViewModelWithPlainObjects:(NSArray *)plainObjs;

@end
