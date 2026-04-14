//
//  MKBaseViewController.h
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBaseViewController : UIViewController

/**
 *  左按钮
 */
@property (nonatomic, strong, readonly) UIButton *leftButton;
/**
 *  右按钮
 */
@property (nonatomic, strong, readonly) UIButton *rightButton;
/**
 *  controlle是否是 经过 presentViewController:animated:completion: 推出来，默认为NO
 */
@property (nonatomic, assign) BOOL isPrensent;
/**
 标题栏文字
 */
@property (nonatomic, copy) NSString *defaultTitle;

/**
 自定义导航栏颜色
 */
@property (nonatomic, strong, nullable) UIColor *navBarBackgroundColor;

/**
 *  设置导航栏标题字体
 */
- (void)setNavTitleFont:(UIFont *)font;

/**
 *  设置导航栏标题颜色
 */
- (void)setNavTitleColor:(UIColor *)color;

/**
 *  设置导航栏背景颜色
 *
 *  @param image 图片
 */
- (void)setNavigationBarImage:(UIImage *)image;

/**
 *  左按钮方法
 */
- (void)leftButtonMethod;

/**
 *  右按钮方法
 */
- (void)rightButtonMethod;

/**
 *  判断当前显示的是否是本控制器
 */
+ (BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;

- (void)popToViewControllerWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
