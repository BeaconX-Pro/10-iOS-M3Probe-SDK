//
//  MKBaseViewController.m
//  MKBaseModuleLibrary
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKBaseViewController.h"
#import "MKCustomNavigationBar.h"
#import "MKMacroDefines.h"

@interface MKBaseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) MKCustomNavigationBar *customNavBar;

@end

@implementation MKBaseViewController

#pragma mark - Lazy Load
- (UIButton *)leftButton {
    return self.customNavBar.leftButton;
}

- (UIButton *)rightButton {
    return self.customNavBar.rightButton;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self setupCustomNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.view bringSubviewToFront:self.customNavBar];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
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

- (void)setNavBarBackgroundColor:(UIColor *)navBarBackgroundColor {
    _navBarBackgroundColor = navBarBackgroundColor;
    self.customNavBar.barBackgroundColor = navBarBackgroundColor ?: NAVBAR_COLOR_MACROS;
}

- (void)setNavigationBarImage:(UIImage *)image {
    self.customNavBar.barBackgroundImage = image;
}

#pragma mark - Custom Method
- (void)setupCustomNavigationBar {
    self.customNavBar = [MKCustomNavigationBar CustomNavigationBar];
    self.customNavBar.barBackgroundColor = self.navBarBackgroundColor ?: NAVBAR_COLOR_MACROS;
    self.customNavBar.titleLabelColor = COLOR_WHITE_MACROS;
    self.customNavBar.titleLabelFont = MKFont(18.f);
    
    // 设置标题
    [self updateTitle];
    
    // 设置默认左按钮
    UIImage *backImage = LOADICON(@"MKBaseModuleLibrary", @"MKBaseViewController", @"navigation_back_button_white.png");
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.leftButton setImage:backImage forState:UIControlStateNormal];
    self.leftButton.hidden = NO;
    
    // 设置按钮点击事件
    [self.leftButton addTarget:self action:@selector(leftButtonMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonMethod) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.customNavBar];
}

- (void)updateTitle {
    NSString *titleText = self.defaultTitle ?: self.title;
    if (titleText.length > 0) {
        self.customNavBar.title = titleText;
    }
}

- (void)setDefaultTitle:(NSString *)defaultTitle {
    _defaultTitle = defaultTitle;
    [self updateTitle];
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

@end
