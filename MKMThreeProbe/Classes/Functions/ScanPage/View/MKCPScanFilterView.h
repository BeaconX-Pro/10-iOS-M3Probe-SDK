//
//  MKCPScanFilterView.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/1/11.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPScanFilterView : UIView

/// 加载扫描过滤页面
/// @param deviceName 过滤的deviceName
/// @param rssi 过滤的rssi
/// @param searchBlock 回调
+ (void)showSearchDeviceName:(NSString *)deviceName
                        rssi:(NSInteger)rssi
                 searchBlock:(void (^)(NSString *deviceName, NSInteger searchRssi))searchBlock;

@end

NS_ASSUME_NONNULL_END
