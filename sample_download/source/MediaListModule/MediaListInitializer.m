//
//  MediaListInitializer.m
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
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
    
    self.mediaListView.mediaList = [self p_generatePlainMediaObjsWithArray: @[
      @{@"entry_id": @"1_jqt5xrs1", @"flavor_id": @"1_t44vxdmb", @"partner_id": @"2164401", @"uiconf_id": @"35748841", @"localName": @"kaltura_test_video_1.mp4"},
      @{@"entry_id": @"1_jp0fiw3x", @"flavor_id": @"1_kq2p4qhp", @"partner_id": @"2164401", @"uiconf_id": @"35748841", @"localName": @"kaltura_test_video_2.mp4"}]];//@"1_jp0fiw3x"
}

- (NSArray *) p_generatePlainMediaObjsWithArray: (NSArray *)array {
    
    NSMutableArray *plainObjs = [NSMutableArray array];
    for (NSDictionary *dictionary in array) {
        
        [plainObjs addObject: [self mapperWithExternalRepresentation: dictionary]];
    }
    
    return plainObjs;
}

- (MediaPlainObject *) mapperWithExternalRepresentation: (NSDictionary *)dictionary {
    
    MediaPlainObject *plain = [[MediaPlainObject alloc] init];
    
    plain.image = [UIImage imageNamed:@"media_placeholder"];
    
    id entryIdObject = [dictionary objectForKey: @"entry_id"];
    if ([entryIdObject isKindOfClass: [NSString class]]) {
        
        plain.entryId = (NSString *)entryIdObject;
    }
    
    id flavorIdObject = [dictionary objectForKey: @"flavor_id"];
    if ([flavorIdObject isKindOfClass: [NSString class]]) {
        
        plain.flavorId = (NSString *)flavorIdObject;
    }
    
    id partnerIdObject = [dictionary objectForKey: @"partner_id"];
    if ([partnerIdObject isKindOfClass: [NSString class]]) {
        
        plain.partnerId = (NSString *)partnerIdObject;
    }
    
    id uiconfIdObject = [dictionary objectForKey: @"uiconf_id"];
    if ([uiconfIdObject isKindOfClass: [NSString class]]) {
        
        plain.uiconfId = (NSString *)uiconfIdObject;
    }
    
    id localNameObject = [dictionary objectForKey: @"localName"];
    if ([localNameObject isKindOfClass: [NSString class]]) {
        
        plain.name = (NSString *)localNameObject;
    }
    
    return plain;
}

@end
