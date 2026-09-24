//
//  SceneDelegate.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2026/9/24.
//  Copyright © 2026 lovexiaoxia. All rights reserved.
//

#import "SceneDelegate.h"

#import "MKCPScanViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    
    // 创建 window 并绑定到 scene
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 设置 rootViewController
    MKCPScanViewController *vc = [[MKCPScanViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // 场景被释放时调用（不一定会调用）
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // 场景从非活跃状态进入活跃状态
}

- (void)sceneWillResignActive:(UIScene *)scene {
    // 场景即将从活跃状态进入非活跃状态
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // 场景即将进入前台
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    // 场景进入后台
}

@end
