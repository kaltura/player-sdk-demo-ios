//
//  KPIconsFetcher.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 9/17/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "KPIconsFetcher.h"

//http://cfvod.kaltura.com/p/1831271/sp/183127100/thumbnail/entry_id/1_o426d3i4/version/100001/acv/151/width/100


@implementation KPIconsFetcher
NSURLRequest *request(NSString *partnerId, NSString *entryId) {
    NSString *link = [NSString stringWithFormat:@"http://cfvod.kaltura.com/p/%@/sp/%@00/thumbnail/entry_id/%@/version/100001/acv/151/width/100", partnerId, partnerId, entryId];
    NSURL *url = [NSURL URLWithString:link];
    return [NSURLRequest requestWithURL:url];
}

+ (void)fetchIconWithPartnerId:(NSString *)partnerId entryId:(NSString *)entryId completion:(void (^)(UIImage *, NSError *))comletion {
    [NSURLConnection sendAsynchronousRequest:request(partnerId, entryId)
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   comletion(nil, connectionError);
                               } else if (data) {
                                   comletion([UIImage imageWithData:data], nil);
                               }
                           }];
}
@end
