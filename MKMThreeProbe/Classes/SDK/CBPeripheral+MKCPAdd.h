//
//  CBPeripheral+MKCPAdd.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKCPAdd)

#pragma mark - eddyStone服务下面的特征

@property (nonatomic, strong, readonly)CBCharacteristic *cp_activeSlot;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_advertisingInterval;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_radioTxPower;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_advertisedTxPower;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_lockState;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_unlock;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_advSlotData;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_factoryReset;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_remainConnectable;

#pragma mark - iBeacon设置服务下面的特征
@property (nonatomic, strong, readonly)CBCharacteristic *cp_customWrite;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_customNotify;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_deviceType;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_slotType;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_voltage;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_disconnectListen;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_threeSensor;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_temperatureHumidity;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_hallSensor;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_batteryHistory;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_tofData;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_waterLeakage;
@property (nonatomic, strong, readonly)CBCharacteristic *cp_temperature;

#pragma mark - 系统信息下面的特征
/**
 Manufacturer,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_vendor;

/**
 Product Model,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_modeID;

/**
 Manufacture Date,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_productionDate;

/**
 Hardware Version,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_hardware;

/**
 Firmware Version,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_firmware;

/**
 Software Version,R
 */
@property (nonatomic, strong, readonly)CBCharacteristic *cp_software;

- (void)cp_updateCharacterWithService:(CBService *)service;

- (void)cp_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)cp_connectSuccess;

- (void)cp_setNil;

@end

NS_ASSUME_NONNULL_END
