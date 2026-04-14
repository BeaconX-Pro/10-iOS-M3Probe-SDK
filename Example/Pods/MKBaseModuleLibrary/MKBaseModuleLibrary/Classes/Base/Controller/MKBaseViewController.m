//
//  MKBaseViewController.m
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKBaseViewController.h"
#import "WRCustomNavigationBar.h"
#import "MKMacroDefines.h"
#import "UIButton+MKAdd.h"

@interface MKBaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) WRCustomNavigationBar *customNavBar;

@end

@implementation MKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self setupCustomNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏系统导航栏
    self.navigationController.navigationBarHidden = YES;
    // 确保自定义导航栏在最前面
    [self.view bringSubviewToFront:self.customNavBar];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    // 刷新按钮状态
    [self refreshLeftButton];
    [self refreshRightButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isRootViewController]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

#pragma mark - Event Method
- (void)leftButtonMethod {
    if (self.isPrensent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightButtonMethod {
    // 子类重写
}

#pragma mark - Public Method
- (void)setNavTitleFont:(UIFont *)font {
    self.customNavBar.titleLabelFont = font;
}

- (void)setNavTitleColor:(UIColor *)color {
    self.customNavBar.titleLabelColor = color;
}

#pragma mark - Custom Method
- (void)setupCustomNavigationBar {
    // 创建自定义导航栏
    self.customNavBar = [WRCustomNavigationBar CustomNavigationBar];
    self.customNavBar.barBackgroundColor = self.navBarBackgroundColor ?: NAVBAR_COLOR_MACROS;
    self.customNavBar.titleLabelColor = COLOR_WHITE_MACROS;
    self.customNavBar.titleLabelFont = MKFont(18.f);
    
    // 设置标题
    [self updateTitle];
    
    // 设置按钮
    [self refreshLeftButton];
    [self refreshRightButton];
    
    // 设置点击事件
    __weak typeof(self) weakSelf = self;
    self.customNavBar.onClickLeftButton = ^{
        [weakSelf leftButtonMethod];
    };
    self.customNavBar.onClickRightButton = ^{
        [weakSelf rightButtonMethod];
    };
    
    [self.view addSubview:self.customNavBar];
}

- (void)updateTitle {
    NSString *titleText = self.defaultTitle ?: self.title;
    if (titleText.length > 0) {
        self.customNavBar.title = titleText;
    }
}

- (void)refreshLeftButton {
    UIImage *leftImage = [self.leftButton imageForState:UIControlStateNormal];
    NSString *leftTitle = [self.leftButton titleForState:UIControlStateNormal];
    UIColor *leftTitleColor = [self.leftButton titleColorForState:UIControlStateNormal];
    
    if (leftImage) {
        [self.customNavBar wr_setLeftButtonWithImage:leftImage];
    } else if (leftTitle.length > 0) {
        [self.customNavBar wr_setLeftButtonWithTitle:leftTitle titleColor:leftTitleColor ?: COLOR_WHITE_MACROS];
    } else {
        // 默认返回箭头
        UIImage *backImage = LOADICON(@"MKBaseModuleLibrary", @"MKBaseViewController", @"navigation_back_button_white.png");
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.customNavBar wr_setLeftButtonWithImage:backImage];
    }
}

- (void)refreshRightButton {
    UIImage *rightImage = [self.rightButton imageForState:UIControlStateNormal];
    NSString *rightTitle = [self.rightButton titleForState:UIControlStateNormal];
    UIColor *rightTitleColor = [self.rightButton titleColorForState:UIControlStateNormal];
    
    if (rightImage) {
        [self.customNavBar wr_setRightButtonWithImage:rightImage];
    } else if (rightTitle.length > 0) {
        [self.customNavBar wr_setRightButtonWithTitle:rightTitle titleColor:rightTitleColor ?: COLOR_WHITE_MACROS];
    } else {
        // 隐藏右按钮
        [self.customNavBar wr_setRightButtonWithImage:nil];
    }
}

- (void)setDefaultTitle:(NSString *)defaultTitle {
    _defaultTitle = defaultTitle;
    [self updateTitle];
}

- (void)setNavBarBackgroundColor:(UIColor *)navBarBackgroundColor {
    _navBarBackgroundColor = navBarBackgroundColor;
    self.customNavBar.barBackgroundColor = navBarBackgroundColor ?: NAVBAR_COLOR_MACROS;
}

- (void)setNavigationBarImage:(UIImage *)image {
    self.customNavBar.barBackgroundImage = image;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

+ (BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController {
    return (viewController.isViewLoaded && viewController.view.window);
}

- (void)popToViewControllerWithClassName:(NSString *)className {
    UIViewController *popController = nil;
    for (UIViewController *v in self.navigationController.viewControllers) {
        if ([v isKindOfClass:NSClassFromString(className)]) {
            popController = v;
            break;
        }
    }
    if (popController) {
        [self.navigationController popToViewController:popController animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)isRootViewController {
    return (self == self.navigationController.viewControllers.firstObject);
}

#pragma mark - Lazy Load
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIImage *backImage = LOADICON(@"MKBaseModuleLibrary", @"MKBaseViewController", @"navigation_back_button_white.png");
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_leftButton setImage:backImage forState:UIControlStateNormal];
        [_leftButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.acceptEventInterval = 1.f;
        _leftButton.backgroundColor = [UIColor clearColor];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_rightButton.titleLabel setFont:MKFont(16)];
        [_rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.acceptEventInterval = 1.f;
        _rightButton.backgroundColor = [UIColor clearColor];
    }
    return _rightButton;
}

@end
