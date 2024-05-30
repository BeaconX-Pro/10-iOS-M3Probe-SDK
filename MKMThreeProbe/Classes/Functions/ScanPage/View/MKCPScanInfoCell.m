//
//  MKCPScanInfoCell.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/1/11.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPScanInfoCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"

#import "MKCPScanInfoCellModel.h"

static CGFloat const offset_X = 15.f;
static CGFloat const rssiIconWidth = 22.f;
static CGFloat const rssiIconHeight = 11.f;
static CGFloat const batteryIconWidth = 25.f;
static CGFloat const batteryIconHeight = 25.f;
static CGFloat const connectButtonWidth = 80.f;
static CGFloat const connectButtonHeight = 30.f;

@interface MKCPScanInfoCell ()

/**
 信号icon
 */
@property (nonatomic, strong)UIImageView *rssiIcon;

/**
 信号强度
 */
@property (nonatomic, strong)UILabel *rssiLabel;

/**
 mac地址
 */
@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UIButton *connectButton;

@property (nonatomic, strong)UIView *centerLine;

@property (nonatomic, strong)UILabel *probeLabel;

@property (nonatomic, strong)UIImageView *bluePoint;

@property (nonatomic, strong)UILabel *waterLabel;

@property (nonatomic, strong)UILabel *waterStatusLabel;

@property (nonatomic, strong)UILabel *temperatureLabel;

@property (nonatomic, strong)UILabel *temperatureValueLabel;

@property (nonatomic, strong)UILabel *humidityLabel;

@property (nonatomic, strong)UILabel *humidityValueLabel;

@property (nonatomic, strong)UILabel *tofLabel;

@property (nonatomic, strong)UILabel *tofValueLabel;

@end

@implementation MKCPScanInfoCell

+ (MKCPScanInfoCell *)initCellWithTableView:(UITableView *)tableView{
    MKCPScanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCPScanInfoCellIdenty"];
    if (!cell) {
        cell = [[MKCPScanInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCPScanInfoCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.rssiIcon];
        [self.contentView addSubview:self.rssiLabel];
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.connectButton];
        
        [self.contentView addSubview:self.centerLine];
        
        [self.contentView addSubview:self.bluePoint];
        [self.contentView addSubview:self.probeLabel];
        [self.contentView addSubview:self.waterLabel];
        [self.contentView addSubview:self.waterStatusLabel];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:4.f];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.rssiIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.top.mas_equalTo(14.f);
        make.width.mas_equalTo(rssiIconWidth);
        make.height.mas_equalTo(rssiIconHeight);
    }];
    [self.rssiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.rssiIcon.mas_centerX);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(self.rssiIcon.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rssiIcon.mas_right).mas_offset(20.f);
        make.centerY.mas_equalTo(self.rssiIcon.mas_centerY);
        make.right.mas_equalTo(-15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.connectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(connectButtonWidth);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(connectButtonHeight);
    }];
    
    [self.centerLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.rssiLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
    [self.bluePoint mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.rssiLabel.mas_centerX);
        make.width.mas_equalTo(7.f);
        make.top.mas_equalTo(self.centerLine.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(7.f);
    }];
    
    [self.probeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceNameLabel.mas_left);
        make.right.mas_equalTo(-offset_X);
        make.centerY.mas_equalTo(self.bluePoint.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.waterLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceNameLabel.mas_left);
        make.right.mas_equalTo(self.waterStatusLabel.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(self.bluePoint.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(11.f).lineHeight);
    }];
    [self.waterStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80.f);
        make.right.mas_equalTo(-offset_X);
        make.centerY.mas_equalTo(self.waterLabel.mas_centerY);
        make.height.mas_equalTo(MKFont(11.f).lineHeight);
    }];
    if (self.dataModel.supportT) {
        [self.temperatureLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.deviceNameLabel.mas_left);
            make.right.mas_equalTo(self.temperatureValueLabel.mas_left).mas_offset(-10.f);
            make.top.mas_equalTo(self.waterLabel.mas_bottom).mas_offset(5.f);
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
        [self.temperatureValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80.f);
            make.right.mas_equalTo(-offset_X);
            make.centerY.mas_equalTo(self.temperatureLabel.mas_centerY);
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
    }
    if (self.dataModel.supportH) {
        [self.humidityLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.deviceNameLabel.mas_left);
            make.right.mas_equalTo(self.humidityValueLabel.mas_left).mas_offset(-10.f);
            if (self.dataModel.supportT) {
                make.top.mas_equalTo(self.temperatureLabel.mas_bottom).mas_offset(5.f);
            }else {
                make.top.mas_equalTo(self.waterLabel.mas_bottom).mas_offset(5.f);
            }
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
        [self.humidityValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80.f);
            make.right.mas_equalTo(-offset_X);
            make.centerY.mas_equalTo(self.humidityLabel.mas_centerY);
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
    }
    if (self.dataModel.supportTof) {
        [self.tofLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.deviceNameLabel.mas_left);
            make.right.mas_equalTo(self.tofValueLabel.mas_left).mas_offset(-10.f);
            if (self.dataModel.supportH) {
                make.top.mas_equalTo(self.humidityLabel.mas_bottom).mas_offset(5.f);
            }else if (self.dataModel.supportT) {
                make.top.mas_equalTo(self.temperatureLabel.mas_bottom).mas_offset(5.f);
            }else {
                make.top.mas_equalTo(self.waterLabel.mas_bottom).mas_offset(5.f);
            }
            
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
        [self.tofValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80.f);
            make.right.mas_equalTo(-offset_X);
            make.centerY.mas_equalTo(self.tofLabel.mas_centerY);
            make.height.mas_equalTo(MKFont(11.f).lineHeight);
        }];
    }
}

#pragma mark - event method
- (void)connectButtonPressed {
    if ([self.delegate respondsToSelector:@selector(cp_scanInfoCell_connect:)]) {
        [self.delegate cp_scanInfoCell_connect:self.dataModel.peripheral];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKCPScanInfoCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKCPScanInfoCellModel.class]) {
        return;
    }
    
    self.rssiLabel.text = [SafeStr(_dataModel.rssi) stringByAppendingString:@"dBm"];
    self.deviceNameLabel.text = (ValidStr(_dataModel.deviceName) ? _dataModel.deviceName : @"N/A");
    self.connectButton.hidden = !_dataModel.connectable;
    self.waterStatusLabel.text = (_dataModel.waterLeakage ? @"YES" : @"NO");
    
    if (self.temperatureLabel.superview) {
        [self.temperatureLabel removeFromSuperview];
    }
    if (self.temperatureValueLabel.superview) {
        [self.temperatureValueLabel removeFromSuperview];
    }
    if (self.humidityLabel.superview) {
        [self.humidityLabel removeFromSuperview];
    }
    if (self.humidityValueLabel.superview) {
        [self.humidityValueLabel removeFromSuperview];
    }
    if (self.tofLabel.superview) {
        [self.tofLabel removeFromSuperview];
    }
    if (self.tofValueLabel.superview) {
        [self.tofValueLabel removeFromSuperview];
    }
    
    if (_dataModel.supportT) {
        [self.contentView addSubview:self.temperatureLabel];
        [self.contentView addSubview:self.temperatureValueLabel];
        self.temperatureValueLabel.text = [NSString stringWithFormat:@"%@%@",_dataModel.temperature,@"℃"];
    }
    
    if (_dataModel.supportH) {
        [self.contentView addSubview:self.humidityLabel];
        [self.contentView addSubview:self.humidityValueLabel];
        self.humidityValueLabel.text = [NSString stringWithFormat:@"%@%@",_dataModel.humidity,@"%RH"];
    }
    
    if (_dataModel.supportTof) {
        [self.contentView addSubview:self.tofLabel];
        [self.contentView addSubview:self.tofValueLabel];
        self.tofValueLabel.text = [NSString stringWithFormat:@"%@%@",_dataModel.tofRanging,@"mm"];
    }
    [self setNeedsLayout];
}

#pragma mark - getter
- (UIImageView *)rssiIcon{
    if (!_rssiIcon) {
        _rssiIcon = [[UIImageView alloc] init];
        _rssiIcon.image = LOADICON(@"MKMThreeProbe", @"MKCPScanInfoCell", @"cp_scan_rssiIcon.png");
    }
    return _rssiIcon;
}

- (UILabel *)rssiLabel{
    if (!_rssiLabel) {
        _rssiLabel = [self createLabelWithFont:MKFont(10)];
        _rssiLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rssiLabel;
}

- (UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textColor = DEFAULT_TEXT_COLOR;
        _deviceNameLabel.font = MKFont(15.f);
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _deviceNameLabel;
}

- (UIButton *)connectButton {
    if (!_connectButton) {
        _connectButton = [MKCustomUIAdopter customButtonWithTitle:@"CONNECT" 
                                                           target:self
                                                           action:@selector(connectButtonPressed)];
    }
    return _connectButton;
}

- (UIView *)centerLine {
    if (!_centerLine) {
        _centerLine = [[UIView alloc] init];
        _centerLine.backgroundColor = DEFAULT_TEXT_COLOR;
    }
    return _centerLine;
}

- (UIImageView *)bluePoint {
    if (!_bluePoint) {
        _bluePoint = [[UIImageView alloc] init];
        _bluePoint.image = LOADICON(@"MKMThreeProbe", @"MKCPScanInfoCell", @"cp_littleBluePoint.png");
    }
    return _bluePoint;
}

- (UILabel *)probeLabel {
    if (!_probeLabel) {
        _probeLabel = [self createLabelWithFont:MKFont(11.f)];
        _probeLabel.textColor = DEFAULT_TEXT_COLOR;
        _probeLabel.text = @"M3 Probe";
    }
    return _probeLabel;
}

- (UILabel *)waterLabel {
    if (!_waterLabel) {
        _waterLabel = [self createLabelWithFont:MKFont(11.f)];
        _waterLabel.text = @"Water leakage status";
    }
    return _waterLabel;
}

- (UILabel *)waterStatusLabel {
    if (!_waterStatusLabel) {
        _waterStatusLabel = [self createLabelWithFont:MKFont(11.f)];
    }
    return _waterStatusLabel;
}

- (UILabel *)temperatureLabel {
    if (!_temperatureLabel) {
        _temperatureLabel = [self createLabelWithFont:MKFont(11.f)];
        _temperatureLabel.text = @"Temperature";
    }
    return _temperatureLabel;
}

- (UILabel *)temperatureValueLabel {
    if (!_temperatureValueLabel) {
        _temperatureValueLabel = [self createLabelWithFont:MKFont(11.f)];
    }
    return _temperatureValueLabel;
}

- (UILabel *)humidityLabel {
    if (!_humidityLabel) {
        _humidityLabel = [self createLabelWithFont:MKFont(11.f)];
        _humidityLabel.text = @"Humidity";
    }
    return _humidityLabel;
}

- (UILabel *)humidityValueLabel {
    if (!_humidityValueLabel) {
        _humidityValueLabel = [self createLabelWithFont:MKFont(11.f)];
    }
    return _humidityValueLabel;
}

- (UILabel *)tofLabel {
    if (!_tofLabel) {
        _tofLabel = [self createLabelWithFont:MKFont(11.f)];
        _tofLabel.text = @"ToF Ranging distance";
    }
    return _tofLabel;
}

- (UILabel *)tofValueLabel {
    if (!_tofValueLabel) {
        _tofValueLabel = [self createLabelWithFont:MKFont(11.f)];
    }
    return _tofValueLabel;
}

- (UILabel *)createLabelWithFont:(UIFont *)font{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = RGBCOLOR(184, 184, 184);
    label.textAlignment = NSTextAlignmentLeft;
    label.font = font;
    return label;
}

@end
