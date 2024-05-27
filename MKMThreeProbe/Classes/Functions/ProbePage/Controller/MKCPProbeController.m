//
//  MKCPProbeController.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPProbeController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKCPCentralManager.h"

#import "MKCPProbeValueView.h"

@interface MKCPProbeController ()

@property (nonatomic, strong)MKCPProbeValueView *temperatureView;

@property (nonatomic, strong)MKCPProbeValueView *humidityView;

@property (nonatomic, strong)MKCPProbeValueView *waterView;

@end

@implementation MKCPProbeController

- (void)dealloc {
    NSLog(@"MKCPProbeController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotes];
}

#pragma mark - note
- (void)receiveTemperatureData:(NSNotification *)note {
    NSDictionary *dataDic = note.userInfo;
    if (!ValidDict(dataDic)) {
        return;
    }
    self.temperatureView.value = dataDic[@"temperature"];
}

- (void)receiveHTDatas:(NSNotification *)note {
    NSDictionary *dataDic = note.userInfo;
    if (!ValidDict(dataDic)) {
        return;
    }
    self.temperatureView.value = dataDic[@"temperature"];
    self.humidityView.value = dataDic[@"humidity"];
}

- (void)receiveWaterData:(NSNotification *)note {
    NSDictionary *dataDic = note.userInfo;
    if (!ValidDict(dataDic)) {
        return;
    }
    BOOL leakage = [dataDic[@"leakage"] boolValue];
    self.waterView.value = (leakage ? @"Leaked" : @"Normal");
    self.waterView.backgroundColor = (leakage ? [UIColor redColor] : RGBCOLOR(134, 237, 53));
}

#pragma mark - loadSubViews
- (void)loadSubViews {
    self.defaultTitle = [self loadTitle];
    
    [self loadTemperatureView];
    [self loadHumidityView];
    [self loadWaterView];
}

- (NSString *)loadTitle {
    if (self.type == mk_cp_probeControllerType_th) {
        return @"T&H Probe";
    }
    if (self.type == mk_cp_probeControllerType_water) {
        return @"Water leakage Probe";
    }
    return @"Temperature Probe";
}

- (void)loadTemperatureView {
    if (self.type == mk_cp_probeControllerType_water) {
        return;
    }
    [self.view addSubview:self.temperatureView];
    [self.temperatureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.view.mas_centerX).mas_offset(-5.f);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(30.f);
        make.height.mas_equalTo(100.f);
    }];
}

- (void)loadHumidityView {
    if (self.type != mk_cp_probeControllerType_th) {
        return;
    }
    [self.view addSubview:self.humidityView];
    [self.humidityView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_centerX).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(30.f);
        make.height.mas_equalTo(100.f);
    }];
}

- (void)loadWaterView {
    if (self.type != mk_cp_probeControllerType_water) {
        return;
    }
    [self.view addSubview:self.waterView];
    [self.waterView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.view.mas_centerX).mas_offset(-5.f);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).mas_offset(30.f);
        make.height.mas_equalTo(100.f);
    }];
}

- (void)addNotes {
    if (self.type == mk_cp_probeControllerType_temperature) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTemperatureData:)
                                                     name:mk_cp_receiveTemperatureDataNotification
                                                   object:nil];
        [[MKCPCentralManager shared] notifyTemperatureData:YES];
        return;
    }
    if (self.type == mk_cp_probeControllerType_th) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveHTDatas:)
                                                     name:mk_cp_receiveHTDataNotification
                                                   object:nil];
        [[MKCPCentralManager shared] notifyTHData:YES];
        return;
    }
    if (self.type == mk_cp_probeControllerType_water) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveWaterData:)
                                                     name:mk_cp_receiveWaterLeakageDetectionDataNotification
                                                   object:nil];
        [[MKCPCentralManager shared] notifyWaterLeakageDetectionData:YES];
        return;
    }
}

#pragma mark - getter
- (MKCPProbeValueView *)temperatureView {
    if (!_temperatureView) {
        _temperatureView = [[MKCPProbeValueView alloc] init];
        _temperatureView.titleMsg = @"Temperature";
        _temperatureView.leftIcon = LOADICON(@"MKMThreeProbe", @"MKCPProbeController", @"cp_temp_probe.png");
        _temperatureView.value = @"0.0";
        _temperatureView.unit = @"℃";
        _temperatureView.backgroundColor = RGBCOLOR(0, 255, 255);
    }
    return _temperatureView;
}

- (MKCPProbeValueView *)humidityView {
    if (!_humidityView) {
        _humidityView = [[MKCPProbeValueView alloc] init];
        _humidityView.titleMsg = @"Humidity";
        _humidityView.leftIcon = LOADICON(@"MKMThreeProbe", @"MKCPProbeController", @"cp_humidity_probe.png");
        _humidityView.value = @"0.0";
        _humidityView.unit = @"%RH";
        _humidityView.backgroundColor = [UIColor yellowColor];
    }
    return _humidityView;
}

- (MKCPProbeValueView *)waterView {
    if (!_waterView) {
        _waterView = [[MKCPProbeValueView alloc] init];
        _waterView.titleMsg = @"Water Leakage";
        _waterView.leftIcon = LOADICON(@"MKMThreeProbe", @"MKCPProbeController", @"cp_waterleak_probe.png");
        _waterView.value = @"Normal";
        _waterView.unit = @"";
        _waterView.backgroundColor = RGBCOLOR(134, 237, 53);
    }
    return _waterView;
}

@end
