//
//  MKCustomNavigationBar.h
//  MKBaseModuleLibrary_Example
//
//  Created by aa on 2026/4/17.
//  Copyright © 2026 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCustomNavigationBar : UIView

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) UIColor  *titleLabelColor;
@property (nonatomic, strong) UIFont   *titleLabelFont;
@property (nonatomic, strong) UIColor  *barBackgroundColor;
@property (nonatomic, strong) UIImage  *barBackgroundImage;

// 左右按钮（可直接操作，设置图片、标题、点击事件等）
@property (nonatomic, strong, readonly) UIButton *leftButton;
@property (nonatomic, strong, readonly) UIButton *rightButton;

+ (instancetype)CustomNavigationBar;

- (void)mk_setBottomLineHidden:(BOOL)hidden;
- (void)mk_setBackgroundAlpha:(CGFloat)alpha;
- (void)mk_setTintColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
