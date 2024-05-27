//
//  MKCPScanSearchButton.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/1/11.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPScanSearchButtonModel : NSObject

/// 显示的标题
@property (nonatomic, copy)NSString *placeholder;

/// 显示的搜索名字
@property (nonatomic, copy)NSString *searchCondition;

/// 过滤的RSSI值
@property (nonatomic, assign)NSInteger searchRssi;

/// 过滤的最小RSSI值，当searchRssi == minSearchRssi时，不显示searchRssi搜索条件
@property (nonatomic, assign)NSInteger minSearchRssi;

@end

@protocol MKCPScanSearchButtonDelegate <NSObject>

/// 搜索按钮点击事件
- (void)cp_scanSearchButtonMethod;

/// 搜索按钮右侧清除按钮点击事件
- (void)cp_scanSearchButtonClearMethod;

@end

@interface MKCPScanSearchButton : UIControl

@property (nonatomic, strong)MKCPScanSearchButtonModel *dataModel;

@property (nonatomic, weak)id <MKCPScanSearchButtonDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
