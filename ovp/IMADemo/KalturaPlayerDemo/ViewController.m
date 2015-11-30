//
//  ViewController.m
//  KalturaPlayerDemo
//
//  Created by Nissim Pardo on 5/31/15.
//  Copyright (c) 2015 kaltura. All rights reserved.
//

#import "ViewController.h"
#import <KALTURAPlayerSDK/KPViewController.h>
#import "PartialPlayerViewController.h"
#import "KPlayerTableViewCell.h"
#import "KPIconsFetcher.h"
#import "CollectionOfPlayers.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) KPViewController *player;
@property (nonatomic, strong) UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *playerTableView;
@property (copy, nonatomic) NSDictionary *entries;
@property (copy, nonatomic) NSString *currentEntryId;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_playerTableView registerNib:[UINib nibWithNibName:@"KPlayerTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_player) {
        [_player removePlayer];
        _player = nil;
    }
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:(CGRect){20, 60, 60, 30}];
        [_backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    }
    return _backButton;
}

- (NSDictionary *)entries {
    if (!_entries) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"playersParams" ofType:@"plist"];
        _entries = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _entries;
}

- (void)fullscreenPressed {
    [self presentViewController:self.player animated:YES completion:nil];
    [self.player.view addSubview:self.backButton];
}


- (void)partialScreenPressed {
    [self.backButton removeFromSuperview];
    [self performSegueWithIdentifier:@"PartialScreen" sender:nil];
}

- (void)collectionPlayer {
    [self performSegueWithIdentifier:@"Collection" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller = [(UINavigationController *)segue.destinationViewController viewControllers].firstObject;
    if ([segue.identifier isEqualToString:@"PartialScreen"]) {
        ((PartialPlayerViewController *)controller).player = self.player;
    } else {
        ((CollectionOfPlayers *)controller).entries = _entries.allValues;
    }
}

- (KPViewController *)player {
    if (!_player) {
        // Account Params
        KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithDomain:@"https://cdnapisec.kaltura.com"
                                                               uiConfID:@"26698911"
                                                              partnerId:@"1831271"];
                                  
        
        
        // Video Entry
        config.entryId = _currentEntryId;
        
        // Setting this property will cache the html pages in the limit size
        config.cacheSize = 0.8;
        _player = [[KPViewController alloc] initWithConfiguration:config];
    }
    return _player;
}

- (void)back:(UIButton *)sender {
    [_player dismissViewControllerAnimated:YES completion:^{
        [_player removePlayer];
        _player = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [KPIconsFetcher fetchIconWithPartnerId:@"1831271"
                                   entryId:self.entries.allValues[indexPath.row]
                                completion:^(UIImage *icon, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.icon = icon;
        });
    }];
    cell.playerName = self.entries.allKeys[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentEntryId = _entries.allValues[indexPath.row];
    void (^switchBlock)() = @{
                               @"Full Screen Player": ^{
                                   [self fullscreenPressed];
                               },
                               @"Inline Player": ^{
                                   [self partialScreenPressed];
                               },
                               @"Collection Of Players": ^{
                                   [self collectionPlayer];
                               }
                               }[_entries.allKeys[indexPath.row]];
    switchBlock();

}

@end
