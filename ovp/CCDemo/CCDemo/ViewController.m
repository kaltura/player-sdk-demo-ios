//
//  ViewController.m
//  CCDemo
//
//  Created by Nissim Pardo on 02/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "ViewController.h"
#import <GoogleCast/GoogleCast.h>
#import <KalturaPlayerSDK/KPViewController.h>
#import <KalturaPlayerSDK/GoogleCastProvider.h>


@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *playerHolderView;
@property (nonatomic, strong) KPViewController *player;
@property (nonatomic, strong) GoogleCastProvider *castProvider;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame = CGRectMake(0, 0, 24, 24);
    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:frame];
    castButton.tintColor = [UIColor blueColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:castButton];
    self.navItem.rightBarButtonItem = item;
}
- (IBAction)changeMedia:(id)sender {
    if (_player) {
        [_player changeMedia:@"0_90r697at"];
    }
}

- (IBAction)loadPlayer:(UIButton *)sender {
        if (!_player) {
            KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithServer:@"http://kgit.html5video.org/tags/v2.48.4/mwEmbedFrame.php"
                                                                   uiConfID:@"31638861"
                                                                  partnerId:@"1831271"];
            config.entryId = @"1_o426d3i4";
            [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
            [config addConfigKey:@"chromecast.useKalturaPlayer" withValue:@"true"];

            _player = [[KPViewController alloc] initWithConfiguration:config];
            _castProvider = [[GoogleCastProvider alloc] init];
            [self addChildViewController:_player];
            _player.view.frame = _playerHolderView.bounds;
            [_player.playerController play];
            [_playerHolderView addSubview:_player.view];
            
            
            [[NSNotificationCenter defaultCenter]   addObserver:self
                                                       selector:@selector(appWillTerminate:)
                                                           name:UIApplicationWillTerminateNotification
                                                         object:[UIApplication sharedApplication]];
        }
}

- (IBAction)startCasting:(UIBarButtonItem *)sender {
    sender.tag = sender.tag ? 0 : 1;
//    _player.castProvider = sender.tag ? _castProvider : nil;
//    sender.tintColor = sender.tag ? [UIColor blackColor] : self.defaultTint;
    _player.castProvider = _castProvider;
}


- (void)appWillTerminate:(NSNotification *)note {
    NSLog(@"terminate");
}


- (UIColor *)defaultTint {
    return [UIColor colorWithRed:0
                           green:122.0 / 255.0
                            blue:1
                           alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
