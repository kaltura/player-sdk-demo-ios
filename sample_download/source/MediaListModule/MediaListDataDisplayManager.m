//
//  CCDataDisplayManager.m
//  KalturaCCSample
//
//  Created by Vitaliy Rusinov on 7/27/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "MediaListDataDisplayManager.h"

static NSString * const kMediaListDataDisplayManagerIdentifier = @"KMediaListDataDisplayManagerIdentifier";

@interface MediaListDataDisplayManager ()

@property (nonatomic, strong) NSArray *plainObjs;

@end

@implementation MediaListDataDisplayManager

- (void)updateTableViewModelWithPlainObjects:(NSArray *)plainObjs {
    
    self.plainObjs = [plainObjs copy];
    
    if ([_delegate respondsToSelector: @selector(didUpdateForDataDisplayManager:)]) {
        
        [_delegate didUpdateForDataDisplayManager: self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _plainObjs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kMediaListDataDisplayManagerIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: kMediaListDataDisplayManagerIdentifier];
    }
    
    MediaPlainObject *plain = _plainObjs[indexPath.row];
    if (plain) {
        
        cell.textLabel.text = plain.name;
        cell.imageView.image = plain.image;
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([_delegate respondsToSelector: @selector(dataDisplayManager:didSelectPlainObj:)]) {
        
        MediaPlainObject *plain = _plainObjs[indexPath.row];
        if (plain) {
            
            [_delegate dataDisplayManager: self didSelectPlainObj: plain];
        }
    }
}

@end
