//
//  ViewController.m
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "MediaListInitializer.h"
#import "MediaListViewController.h"
#import "MediaListDataDisplayManager.h"
#import "MediaPlainObject.h"

@interface MediaListInitializer ()

@property (nonatomic, weak) IBOutlet MediaListViewController *mediaListView;

@end

@implementation MediaListInitializer

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self p_configure];
}

- (void) p_configure {
    
    self.mediaListView.dataDisplayManager = [[MediaListDataDisplayManager alloc] init];
    self.mediaListView.dataDisplayManager.delegate = _mediaListView;
    
    self.mediaListView.tableView.delegate = self.mediaListView.dataDisplayManager;
    self.mediaListView.tableView.dataSource = self.mediaListView.dataDisplayManager;
    
    self.mediaListView.mediaList = [self p_generatePlainMediaObjsWithArrayOfEntryIds: @[@"1_773arzin", @"0_63rji9fo", @"1_elmoexon"]];
}

- (NSArray *) p_generatePlainMediaObjsWithArrayOfEntryIds: (NSArray *)entryIds {
    
    NSMutableArray *plainObjs = [NSMutableArray array];
    for (NSString *entryId in entryIds) {
        
        MediaPlainObject *plain = [[MediaPlainObject alloc] init];
        plain.name = entryId;
        plain.image = [UIImage imageNamed:@"media_placeholder"];
        [plainObjs addObject: plain];
    }
    
    return plainObjs;
}

@end
