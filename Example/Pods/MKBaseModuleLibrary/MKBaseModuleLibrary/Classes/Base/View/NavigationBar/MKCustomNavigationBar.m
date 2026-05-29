//
//  MKCustomNavigationBar.m
//  MKBaseModuleLibrary_Example
//
//  Created by aa on 2026/4/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

#import "MKCustomNavigationBar.h"
#import "MKMacroDefines.h"

@interface MKCustomNavigationBar ()
@property (nonatomic, strong) UILabel     *titleLable;
@property (nonatomic, strong) UIButton    *leftButton;
@property (nonatomic, strong) UIButton    *rightButton;
@property (nonatomic, strong) UIView      *bottomLine;
@property (nonatomic, strong) UIView      *backgroundView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation MKCustomNavigationBar

+ (instancetype)CustomNavigationBar {
    MKCustomNavigationBar *navigationBar = [[self alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, kTopBarHeight)];
    return navigationBar;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.backgroundView];
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.leftButton];
    [self addSubview:self.titleLable];
    [self addSubview:self.rightButton];
    [self addSubview:self.bottomLine];
    [self updateFrame];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = NAVBAR_COLOR_MACROS;
}

- (void)updateFrame {
    CGFloat top = kStatusBarHeight;
    CGFloat margin = 0;
    CGFloat buttonHeight = kNavigationBarHeight;
    CGFloat buttonWidth = 44;
    CGFloat titleLabelHeight = kNavigationBarHeight;
    CGFloat titleLabelWidth = kViewWidth - 120;
    
    self.backgroundView.frame = self.bounds;
    self.backgroundImageView.frame = self.bounds;
    self.leftButton.frame = CGRectMake(margin, top, buttonWidth, buttonHeight);
    self.rightButton.frame = CGRectMake(kViewWidth - buttonWidth - margin, top, buttonWidth, buttonHeight);
    self.titleLable.frame = CGRectMake((kViewWidth - titleLabelWidth) / 2, top, titleLabelWidth, titleLabelHeight);
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height - CUTTING_LINE_HEIGHT, kViewWidth, CUTTING_LINE_HEIGHT);
}

#pragma mark - Public Methods
- (void)mk_setBottomLineHidden:(BOOL)hidden {
    self.bottomLine.hidden = hidden;
}

- (void)mk_setBackgroundAlpha:(CGFloat)alpha {
    self.backgroundView.alpha = alpha;
    self.backgroundImageView.alpha = alpha;
    self.bottomLine.alpha = alpha;
}

- (void)mk_setTintColor:(UIColor *)color {
    [self.leftButton setTitleColor:color forState:UIControlStateNormal];
    [self.rightButton setTitleColor:color forState:UIControlStateNormal];
    [self.titleLable setTextColor:color];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLable.hidden = NO;
    self.titleLable.text = _title;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor {
    _titleLabelColor = titleLabelColor;
    self.titleLable.textColor = _titleLabelColor;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleLable.font = _titleLabelFont;
}

- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor {
    self.backgroundImageView.hidden = YES;
    _barBackgroundColor = barBackgroundColor;
    self.backgroundView.hidden = NO;
    self.backgroundView.backgroundColor = _barBackgroundColor;
}

- (void)setBarBackgroundImage:(UIImage *)barBackgroundImage {
    self.backgroundView.hidden = YES;
    _barBackgroundImage = barBackgroundImage;
    self.backgroundImageView.hidden = NO;
    self.backgroundImageView.image = _barBackgroundImage;
}

#pragma mark - Getter
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] init];
        _leftButton.imageView.contentMode = UIViewContentModeCenter;
        [_leftButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        
        // 修复白色圆环
        _leftButton.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)) {
            _leftButton.configuration = nil;
        }
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;
        [_rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        // 修复白色圆环
        _rightButton.backgroundColor = [UIColor clearColor];
        if (@available(iOS 15.0, *)) {
            _rightButton.configuration = nil;
        }
    }
    return _rightButton;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.textColor = DEFAULT_TEXT_COLOR;
        _titleLable.font = MKFont(18.f);
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.hidden = YES;
    }
    return _titleLable;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _bottomLine;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.hidden = YES;
    }
    return _backgroundImageView;
}

@end
