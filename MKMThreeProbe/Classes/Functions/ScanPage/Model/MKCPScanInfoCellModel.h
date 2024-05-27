//
//  MKCPScanInfoCellModel.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/8/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKCPScanInfoCellModel : NSObject

/**
 peripheral 标识符，用来筛选当前设备列表是否已经存在某一个设备
 */
@property (nonatomic, copy)NSString *identifier;

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, assign)BOOL waterLeakage;

@property (nonatomic, assign)BOOL supportT;

@property (nonatomic, copy)NSString *temperature;

@property (nonatomic, assign)BOOL supportH;

@property (nonatomic, copy)NSString *humidity;

@property (nonatomic, copy)NSString *tofRanging;

@property (nonatomic, assign)BOOL connectable;

@property (nonatomic, copy)NSString *rssi;

@end

NS_ASSUME_NONNULL_END
