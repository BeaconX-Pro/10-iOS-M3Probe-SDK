/**
 头文件说明：
 1、与设备有关的宏定义
 */

#import <UIKit/UIKit.h>

#pragma mark - *************************  block弱引用强引用  *************************
//弱引用对象
#define WS(weakSelf)          __weak __typeof(&*self)weakSelf = self;

#pragma mark - ***************************    优雅的使用弱引用和强引用      **************************
/*
 @weakify(self)

 blcok = ^{
     @strongify(self)
     self.view = ...
 }
 */

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif


#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


#pragma mark - *************************  硬件相关  *************************
/** 获取屏幕尺寸、宽度、高度 */
#define kScreenRect                 ([UIScreen mainScreen].bounds)
#define kViewWidth                  ([UIScreen mainScreen].bounds.size.width)
#define kViewHeight                 ([UIScreen mainScreen].bounds.size.height)

#define kScreenMaxLength            (MAX(kViewWidth, kViewHeight))
#define kScreenMinLength            (MIN(kViewWidth, kViewHeight))


#pragma mark - *************************  系统相关  *************************

#define kAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define kAppWindow \
({ \
    UIWindow *topWindow = nil; \
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) { \
        if (scene.activationState == UISceneActivationStateForegroundActive) { \
            topWindow = scene.windows.firstObject; \
            break; \
        } \
    } \
    topWindow; \
})

#define kAppRootController \
({ \
    UIViewController *rootController = nil; \
    UIWindow *window = kAppWindow; \
    if (window) { \
        rootController = window.rootViewController; \
    } \
    rootController; \
})

/** 获取系统版本 */
#define kSystemVersionString ([NSProcessInfo processInfo].operatingSystemVersionString)

/** 获取APP名称 */
#define kAppName ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"])

/** 获取APP版本 */
#define kAppVersion ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"])

/** 获取APP Build版本 */
#define kAppBuildVersion ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"])

#define iOS(version) ({ \
    BOOL isIOS = NO; \
    if (@available(iOS version, *)) { \
        isIOS = YES; \
    } \
    isIOS; \
})

//获取系统时间戳
#define kSystemTimeStamp [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]


#pragma mark - *************************  状态栏、导航栏、标签栏相关  *************************

/*
    状态栏高度 - 动态获取
 */
#define kStatusBarHeight \
({ \
    CGFloat height = 0; \
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) { \
        if (scene.activationState == UISceneActivationStateForegroundActive) { \
            height = scene.statusBarManager.statusBarFrame.size.height; \
            break; \
        } \
    } \
    if (height == 0) { \
        UIWindow *window = kAppWindow; \
        if (window) { \
            height = window.safeAreaInsets.top; \
        } \
    } \
    if (height == 0) { \
        height = 47; \
    } \
    height; \
})

/**
 *  导航栏高度 - iOS 14 为 44，iOS 15+ 为 54
 */
#define kNavigationBarHeight \
({ \
    CGFloat height = 44; \
    if (@available(iOS 15.0, *)) { \
        height = 54; \
    } \
    height; \
})

/**
 *  导航栏高度（精确获取当前控制器导航栏的实际高度）
 */
#define kNavigationBarHeightExact \
({ \
    CGFloat height = 44; \
    UIViewController *rootVC = kAppRootController; \
    if (rootVC.navigationController) { \
        height = rootVC.navigationController.navigationBar.frame.size.height; \
    } \
    if (height <= 0) { \
        if (@available(iOS 15.0, *)) { \
            height = 54; \
        } else { \
            height = 44; \
        } \
    } \
    height; \
})

/*
    顶部总高度（状态栏 + 导航栏）
 */
#define kTopBarHeight (kStatusBarHeight + kNavigationBarHeight)

/**
 *  底部安全区域高度
 */
#define kSafeAreaHeight \
({ \
    CGFloat bottom = 0; \
    UIWindow *window = kAppWindow; \
    if (window) { \
        bottom = window.safeAreaInsets.bottom; \
    } \
    bottom; \
})

/**
 *  标签栏(底部)高度 - 无刘海屏为 49，有刘海屏为 83
 */
#define kTabBarHeight \
({ \
    CGFloat height = 49; \
    if (kSafeAreaHeight > 0) { \
        height = 83; \
    } \
    height; \
})

/**
 *  顶部安全区域高度（状态栏高度）
 */
#define kSafeAreaTopHeight (kStatusBarHeight)


#pragma mark - *************************  本地文档相关  *************************
/** 获取Documents目录 */
#define kDocumentsPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

/** 获得Documents下指定文件名的文件路径 */
#define kFilePath(filename) ([kDocumentsPath stringByAppendingPathComponent:filename])

/** 获取Library目录 */
#define kLibraryPath ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Caches目录 */
#define kCachesPath ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject])

/** 获取Tmp目录 */
#define kTmpPath NSTemporaryDirectory()

#ifndef moko_dispatch_main_safe
#define moko_dispatch_main_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif


#pragma mark - **************************  字体相关  *********************************
#define MKFont(a) \
({ \
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:a]; \
    if (!font) { \
        font = [UIFont systemFontOfSize:a]; \
    } \
    font; \
})

#define MKLightFont(a) ([UIFont systemFontOfSize:a weight:UIFontWeightLight])
#define MKMediumFont(a) ([UIFont systemFontOfSize:a weight:UIFontWeightMedium])
#define MKBoldFont(a) ([UIFont boldSystemFontOfSize:a])


#pragma mark - **************************  国际化相关  *********************************
#define LS(a) NSLocalizedString(a, nil)

//线的高度
#define CUTTING_LINE_HEIGHT (1.0 / [UIScreen mainScreen].scale)

//图片的宏定义
#define LOADIMAGE(file, ext) \
({ \
    UIImage *image = [UIImage imageNamed:file]; \
    if (!image) { \
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:ext]; \
        image = [UIImage imageWithContentsOfFile:path]; \
    } \
    image; \
})

/*
 podLibName:调用该方法的对象所在的bundle名称
 bundleClassName:调用该方法的对象在bundle里面的名称
 imageName:icon名称，xxx.png
 */
#define LOADICON(podLibName, bundleClassName, imageName) \
({\
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(bundleClassName)];\
    NSString *bundlePath = [bundle pathForResource:podLibName ofType:@"bundle"];\
    UIImage *image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:imageName]];\
    image;\
})


#pragma mark - **************************  设备判断  *********************************
/** 是否是刘海屏（有安全区域） */
#define kIsBangsScreen (kSafeAreaHeight > 0)

/** 是否是iPad */
#define kIsPad (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)

/** 是否是iPhone */
#define kIsPhone (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
