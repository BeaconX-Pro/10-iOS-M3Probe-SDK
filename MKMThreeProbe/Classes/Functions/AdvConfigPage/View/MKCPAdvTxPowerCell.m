//
//  MKCPAdvTxPowerCell.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/27.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPAdvTxPowerCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"
#import "MKSlider.h"

@implementation MKCPAdvTxPowerCellModel
@end

@interface MKCPAdvTxPowerCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *valueLabel;

@property (nonatomic, strong)MKSlider *slider;

@end

@implementation MKCPAdvTxPowerCell

+ (MKCPAdvTxPowerCell *)initCellWithTableView:(UITableView *)tableView {
    MKCPAdvTxPowerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCPAdvTxPowerCellIdenty"];
    if (!cell) {
        cell = [[MKCPAdvTxPowerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCPAdvTxPowerCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.slider];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.valueLabel.mas_left).mas_offset(-5.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(10.f);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.slider.mas_centerY);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)txPowerSliderValueChanged {
    self.valueLabel.text = [self txPowerValueText:self.slider.value];
    if ([self.delegate respondsToSelector:@selector(cp_txPowerValueChanged:)]) {
        [self.delegate cp_txPowerValueChanged:(NSInteger)self.slider.value];
    }
}

#pragma mark - private method
- (NSString *)txPowerValueText:(float)sliderValue{
    if (sliderValue >=0 && sliderValue < 1) {
        return @"-40dBm";
    }
    if (sliderValue >= 1 && sliderValue < 2){
        return @"-20dBm";
    }
    if (sliderValue >= 2 && sliderValue < 3){
        return @"-16dBm";
    }
    if (sliderValue >= 3 && sliderValue < 4){
        return @"-12dBm";
    }
    if (sliderValue >= 4 && sliderValue < 5){
        return @"-8dBm";
    }
    if (sliderValue >= 5 && sliderValue < 6){
        return @"-4dBm";
    }
    if (sliderValue >= 6 && sliderValue < 7){
        return @"0dBm";
    }
    if (sliderValue >= 7 && sliderValue < 8) {
        return @"3dBm";
    }
    if (sliderValue >= 8 && sliderValue <= 9) {
        return @"4dBm";
    }
    
    return @"4dBm";
}

#pragma mark - setter
- (void)setDataModel:(MKCPAdvTxPowerCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.slider.value = _dataModel.txPowerValue;
    self.valueLabel.text = [self txPowerValueText:self.slider.value];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.attributedText = [MKCustomUIAdopter attributedString:@[@"Tx Power",@"   (-40,-20,-16,-12,-8,-4,0,+3,+4)"] fonts:@[MKFont(15.f),MKFont(13.f)] colors:@[DEFAULT_TEXT_COLOR,RGBCOLOR(223, 223, 223)]];
    }
    return _msgLabel;
}

- (MKSlider *)slider {
    if (!_slider) {
        _slider = [[MKSlider alloc] init];
        _slider.maximumValue = 9.f;
        _slider.minimumValue = 0.f;
        _slider.value = 6.f;
        [_slider addTarget:self
                    action:@selector(txPowerSliderValueChanged)
          forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = DEFAULT_TEXT_COLOR;
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.font = MKFont(11.f);
        _valueLabel.text = @"0dBm";
    }
    return _valueLabel;
}

@end
