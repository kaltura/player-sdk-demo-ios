//
//  AssetDownloader.h
//  LocalAssetsDemo
//
//  Created by Noam Tamim on 21/09/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "Asset.h"
#import <KalturaPlayerSDK/KPPlayerConfig.h>
#import <KalturaPlayerSDK/KPAssetRegistrationHelper.h>

@interface AssetDownloader : NSObject
@property (nonatomic) Asset* asset;
@property (nonatomic) kDownloadProgressReport progressReport;
@property (nonatomic) KPAssetRegistrationHelper* assetRegistrationHelper;
- (void)startDownload;
- (instancetype)initWithAsset:(Asset*)asset config:(KPPlayerConfig*)config;
+(AssetDownloader*)downloaderForAsset:(Asset*)asset config:(KPPlayerConfig*)config;
@end
