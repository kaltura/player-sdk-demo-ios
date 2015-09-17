//
//  CollectionOfPlayers.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 7/18/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "CollectionOfPlayers.h"
#import "VideoCell.h"

@interface CollectionOfPlayers() <UICollectionViewDelegateFlowLayout>{
    NSMutableArray *players;
    NSInteger index;
    __weak IBOutlet UIBarButtonItem *leftButton;
    __weak IBOutlet UIBarButtonItem *rightButton;
    NSArray *entries;
}

@end

@implementation CollectionOfPlayers

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[VideoCell class] forCellWithReuseIdentifier:@"VideoCell"];
    entries = @[@"1_o426d3i4", @"1_u202oxs5", @"1_iwhl2pu8"];
}

- (IBAction)changePlayerPressed:(UIBarButtonItem *)sender {
    if (sender.tag) {
        index++;
    } else {
        index--;
    }
    rightButton.enabled = index < 2;
    leftButton.enabled = index > 0;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    cell.parentController = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *_cell = (VideoCell *)[collectionView visibleCells].firstObject;
    if ([collectionView indexPathForCell:_cell].row != indexPath.row) {
        [_cell.player sendNotification:@"doPause" withParams:nil];
        _cell.entryId = entries[[collectionView indexPathForCell:_cell].row];
        [[(VideoCell *)cell player] sendNotification:@"doPlay" withParams:nil];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (CGSize){self.view.frame.size.width - 20, 376};
}

@end
