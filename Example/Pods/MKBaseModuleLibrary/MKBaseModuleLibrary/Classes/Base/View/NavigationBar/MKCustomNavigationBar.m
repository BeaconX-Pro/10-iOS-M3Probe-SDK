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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    CGFloat top = kStatusBarHeight;
    CGFloat leftMargin = 12;   // 左边距
    CGFloat rightMargin = 12;  // 右边距
    CGFloat buttonHeight = kNavigationBarHeight;
    
    // 动态计算按钮宽度
    CGFloat leftButtonWidth = [self calculateButtonWidth:self.leftButton];
    CGFloat rightButtonWidth = [self calculateButtonWidth:self.rightButton];
    
    // 限制按钮宽度范围（最小44，最大120）
    leftButtonWidth = MAX(44, MIN(120, leftButtonWidth));
    rightButtonWidth = MAX(44, MIN(120, rightButtonWidth));
    
    // 计算标题可用宽度
    CGFloat titleLabelMaxWidth = kViewWidth - leftButtonWidth - rightButtonWidth - leftMargin - rightMargin - 10;
    CGFloat titleLabelWidth = MIN(titleLabelMaxWidth, 200);
    
    self.backgroundView.frame = self.bounds;
    self.backgroundImageView.frame = self.bounds;
    
    // 左按钮（距离左边 leftMargin）
    self.leftButton.frame = CGRectMake(leftMargin, top, leftButtonWidth, buttonHeight);
    
    // 右按钮（距离右边 rightMargin）
    self.rightButton.frame = CGRectMake(kViewWidth - rightButtonWidth - rightMargin, top, rightButtonWidth, buttonHeight);
    
    // 标题居中
    self.titleLable.frame = CGRectMake(
        (kViewWidth - titleLabelWidth) / 2,
        top,
        titleLabelWidth,
        buttonHeight
    );
    
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height - CUTTING_LINE_HEIGHT, kViewWidth, CUTTING_LINE_HEIGHT);
}

// 计算按钮实际需要的宽度
- (CGFloat)calculateButtonWidth:(UIButton *)button {
    NSString *title = [button titleForState:UIControlStateNormal];
    UIImage *image = [button imageForState:UIControlStateNormal];
    
    CGFloat width = 44; // 最小宽度
    UIFont *font = button.titleLabel.font ?: [UIFont systemFontOfSize:16];
    
    // 如果有文字，计算文字宽度
    if (title.length > 0) {
        NSDictionary *attributes = @{NSFontAttributeName: font};
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil].size;
        width = textSize.width + 20; // 文字宽度 + 左右内边距
    }
    
    // 如果有图片，且没有文字，增加图片宽度
    if (image && title.length == 0) {
        width = image.size.width + 20;
    }
    
    // 如果同时有图片和文字
    if (title.length > 0 && image) {
        NSDictionary *attributes = @{NSFontAttributeName: font};
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil].size;
        width = textSize.width + image.size.width + 24;
    }
    
    return width;
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
    [self setNeedsLayout];
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor {
    _titleLabelColor = titleLabelColor;
    self.titleLable.textColor = _titleLabelColor;
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    self.titleLable.font = _titleLabelFont;
    [self setNeedsLayout];
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
        _leftButton.titleLabel.font = MKFont(15.f);
        
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
        _rightButton.titleLabel.font = MKFont(15.f);
        
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
