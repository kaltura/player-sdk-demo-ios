//
//  ViewController.m
//  CCDemo
//
//  Created by Nissim Pardo on 02/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "ViewController.h"
#import "DevicesInRangeViewController.h"


@interface ViewController () <KCastProviderDelegate, DevicesInRangeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UIView *playerHolderView;
@property (nonatomic, strong) KPViewController *player;
@property (nonatomic, strong) KCastProvider *castProvider;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *castButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _castProvider = [[KCastProvider alloc] init];
    _castProvider.delegate = self;
    [_castProvider startScan:@"C43947A1"];
}

- (IBAction)loadPlayer:(UIButton *)sender {
        if (!_player) {
            KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithServer:@"http://kgit.html5video.org/tags/v2.43.rc11/mwEmbedFrame.php"
                                                                   uiConfID:@"31638861"
                                                                  partnerId:@"1831271"];
            config.entryId = @"1_o426d3i4";
            [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
            [config addConfigKey:@"chromecast.useKalturaPlayer" withValue:@"true"];
            [config addConfigKey:@"chromecast.applicationID" withValue:@"C43947A1"];
            [config addConfigKey:@"doubleClick.plugin" withValue:@"false"];
//            [config addConfigKey:@"doubleClick.adTagUrl" withValue:@"http://pubads.g.doubleclick.net/gampad/ads?sz=640x360&iu=/6062/iab_vast_samples/skippable&ciu_szs=300x250,728x90&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&correlator=[timestamp]"];
            _player = [[KPViewController alloc] initWithConfiguration:config];
            _player.castProvider = _castProvider;
            [self addChildViewController:_player];
            _player.view.frame = _playerHolderView.bounds;
            [_playerHolderView addSubview:_player.view];
        }
}

- (IBAction)presentDevice:(UIBarButtonItem *)sender {
    sender.tag = sender.tag ? 0 : 1;
    [self performSegueWithIdentifier:@"PresentDevices" sender:@(sender.tag)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DevicesInRangeViewController *controller = segue.destinationViewController;
    if ([sender boolValue]) {
        controller.devices = _castProvider.devices;
    } else {
        controller.device = _castProvider.selectedDevice;
    }
    controller.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectDevice:(KCastDevice *)device {
    [_castProvider connectToDevice:device];
}

- (void)disconnect {
    [_castProvider disconnectFromDevice];
}


- (void)castProvider:(KCastProvider *)provider devicesInRange:(BOOL)foundDevices {
    _castButton.enabled = foundDevices;
}

- (void)castProvider:(KCastProvider *)provider didDeviceComeOnline:(KCastDevice *)device {
    
}

- (void)castProvider:(KCastProvider *)provider didDeviceGoOffline:(KCastDevice *)device {
    
}

- (void)didConnectToDevice:(KCastProvider *)provider {
    _castButton.tintColor = [UIColor blackColor];
}

- (void)didDisconnectFromDevice:(KCastProvider *)provider {
    _castButton.tintColor = [UIColor blueColor];
}

- (void)castProvider:(KCastProvider *)provider didFailToConnectToDevice:(NSError *)error {
    
}
- (void)castProvider:(KCastProvider *)provider didFailToDisconnectFromDevice:(NSError *)error {
    
}

@end
