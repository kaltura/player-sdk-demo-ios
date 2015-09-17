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

@interface ViewController ()
@property (nonatomic,strong) KPViewController *player;
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak ViewController *weakSelf = self;
    [self.player addKPlayerEventListener:@"play" eventID:@"play1" handler:^(NSString *eventName, NSString *params) {
        weakSelf.backButton.hidden = YES;
    }];
    
    [self.player addKPlayerEventListener:@"pause" eventID:@"pause1" handler:^(NSString *eventName, NSString *params) {
        weakSelf.backButton.hidden = NO;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player removeKPlayerEventListener:@"play" eventID:@"play1"];
    [self.player removeKPlayerEventListener:@"pause" eventID:@"pause1"];
    [super viewWillDisappear:animated];
}

- (IBAction)fullscreenPressed:(UIButton *)sender {
    [self presentViewController:self.player animated:YES completion:nil];
    [self.player.view addSubview:self.backButton];
}


- (IBAction)partialScreenPressed:(UIButton *)sender {
    [self.backButton removeFromSuperview];
    [self performSegueWithIdentifier:@"PartialScreen" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue.identifier) {
        PartialPlayerViewController *controller = [(UINavigationController *)segue.destinationViewController viewControllers].firstObject;
        controller.player = self.player;
    }
}

- (KPViewController *)player {
    if (!_player) {
        // Account Params
        KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithDomain:@"http://cdnapi.kaltura.com"
                                                               uiConfID:@"26698911"
                                                              partnerId:@"1831271"];
                                  
        
        
        // Video Entry
        config.entryId = @"1_o426d3i4";
        
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

@end
