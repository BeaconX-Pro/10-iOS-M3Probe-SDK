//
//  MKCPSensorCell.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPSensorCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKCPSensorCellModel
@end

@interface MKCPSensorCell ()

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *detailMsgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKCPSensorCell

+ (MKCPSensorCell *)initCellWithTableView:(UITableView *)tableView{
    MKCPSensorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKCPSensorCellIdenty"];
    if (!cell) {
        cell = [[MKCPSensorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCPSensorCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.detailMsgLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(35.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.leftIcon.mas_centerY).mas_offset(-5.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-10.f);
    }];
    [self.detailMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftIcon.mas_centerY).mas_offset(5.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-10.f);
    }];
    [self.rightIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(14.f);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKCPSensorCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKCPSensorCellModel.class]) {
        return;
    }
    
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.detailMsgLabel.text = SafeStr(_dataModel.detailMsg);
    self.leftIcon.image = _dataModel.icon;
}

#pragma mark - getter
- (UIImageView *)leftIcon{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    return _leftIcon;
}

- (UIImageView *)rightIcon{
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADICON(@"MKMThreeProbe", @"MKCPSensorCell", @"cp_goNextButton.png");
    }
    return _rightIcon;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [self createLabelWithFont:MKFont(15.0)];
    }
    return _msgLabel;
}

- (UILabel *)detailMsgLabel {
    if (!_detailMsgLabel) {
        _detailMsgLabel = [self createLabelWithFont:MKFont(11.f)];
    }
    return _detailMsgLabel;
}

- (UILabel *)createLabelWithFont:(UIFont *)font{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = DEFAULT_TEXT_COLOR;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = font;
    return label;
}

@end
