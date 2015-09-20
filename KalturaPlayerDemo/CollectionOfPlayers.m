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
    NSInteger index;
    UIBarButtonItem *leftButton;
    __weak IBOutlet UIBarButtonItem *rightButton;
}
@property (copy, nonatomic) NSMutableSet *players;
@end

@implementation CollectionOfPlayers

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[VideoCell class] forCellWithReuseIdentifier:@"VideoCell"];
    leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(changePlayerPressed:)];
    leftButton.enabled = NO;
    NSArray *arr = [self.navigationItem.rightBarButtonItems arrayByAddingObject:leftButton];
    self.navigationItem.rightBarButtonItems = arr;
    self.title = @"Player Collection";
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

- (IBAction)backPressed:(UIBarButtonItem *)sender {
    for (KPViewController *player in _players) {
        [player.playerController pause];
        [player removePlayer];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableSet *)players {
    if (!_players) {
        _players = [NSMutableSet new];
    }
    return _players;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    cell.parentController = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *_cell = (VideoCell *)[collectionView visibleCells].firstObject;
    if ([collectionView indexPathForCell:_cell].row != indexPath.row) {
        [_cell.player.playerController pause];
        _cell.entryId = _entries[[collectionView indexPathForCell:_cell].row];
        [[(VideoCell *)cell player].playerController play];
        [self.players addObject:((VideoCell *)cell).player];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (CGSize){self.view.frame.size.width - 20, 376};
}

@end
