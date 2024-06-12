//
//  CBPeripheral+MKCPAdd.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "CBPeripheral+MKCPAdd.h"

#import <objc/runtime.h>

#import "MKCPService.h"

static const char *cp_activeSlot = "cp_activeSlot";
static const char *cp_advertisingInterval = "cp_advertisingInterval";
static const char *cp_radioTxPower = "cp_radioTxPower";
static const char *cp_advertisedTxPower = "cp_advertisedTxPower";
static const char *cp_lockState = "cp_lockState";
static const char *cp_unlock = "cp_unlock";
static const char *cp_advSlotData = "cp_advSlotData";
static const char *cp_factoryReset = "cp_factoryReset";
static const char *cp_remainConnectable = "cp_remainConnectable";

static const char *cp_deviceTypeKey = "cp_deviceTypeKey";
static const char *cp_slotTypeKey = "cp_slotTypeKey";
static const char *cp_voltage = "cp_voltage";
static const char *cp_disconnectListenKey = "cp_disconnectListenKey";
static const char *cp_threeSensorKey = "cp_threeSensorKey";
static const char *cp_temperatureHumidityKey = "cp_temperatureHumidityKey";
static const char *cp_hallSensorKey = "cp_hallSensorKey";
static const char *cp_batteryHistoryKey = "cp_batteryHistoryKey";
static const char *cp_tofDataKey = "cp_tofDataKey";
static const char *cp_waterLeakageKey = "cp_waterLeakageKey";
static const char *cp_temperatureKey = "cp_temperatureKey";

static const char *cp_customWrite = "cp_customWrite";
static const char *cp_customNotify = "cp_customNotify";

static const char *cp_vendor = "cp_vendor";
static const char *cp_modeID = "cp_modeID";
static const char *cp_hardware = "cp_hardware";
static const char *cp_firmware = "cp_firmware";
static const char *cp_software = "cp_software";
static const char *cp_productionDate = "cp_productionDate";

static const char *cp_customNotifySuccessKey = "cp_customNotifySuccessKey";
static const char *cp_disconnectListenSuccessKey = "cp_disconnectListenSuccessKey";

@implementation CBPeripheral (MKCPAdd)

- (void)cp_updateCharacterWithService:(CBService *)service {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_configServiceUUID]]) {
        //eddyStone通用配置服务
        [self cp_updateEddystoneCharacteristic:service];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_customServiceUUID]]){
        //自定义配置服务
        [self cp_updateCustomCharacteristic:service];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_deviceServiceUUID]]){
        //系统信息(软件版本、硬件版本等)
        [self cp_updateDeviceInfoCharacteristic:service];
        return;
    }
}

- (void)cp_updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_notifyUUID]]){
        objc_setAssociatedObject(self, &cp_customNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_disconnectListenUUID]]) {
        objc_setAssociatedObject(self, &cp_disconnectListenSuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)cp_connectSuccess {
    if (![objc_getAssociatedObject(self, &cp_customNotifySuccessKey) boolValue] || ![objc_getAssociatedObject(self, &cp_disconnectListenSuccessKey) boolValue]) {
        return NO;
    }
    if (![self cp_serviceSuccess] || ![self cp_customServiceSuccess]) {
        return NO;
    }
    return YES;
}

- (void)cp_setNil {
    objc_setAssociatedObject(self, &cp_activeSlot, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_advertisingInterval, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_radioTxPower, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_advertisedTxPower, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_lockState, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_unlock, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_advSlotData, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_factoryReset, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_remainConnectable, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cp_customNotify, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_customWrite, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_deviceTypeKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_slotTypeKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_voltage, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_disconnectListenKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_threeSensorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_temperatureHumidityKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_hallSensorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_batteryHistoryKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_tofDataKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_waterLeakageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_temperatureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cp_vendor, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_modeID, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_hardware, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_firmware, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_software, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_productionDate, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &cp_customNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &cp_disconnectListenSuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (CBCharacteristic *)cp_activeSlot{
    return objc_getAssociatedObject(self, &cp_activeSlot);
}

- (CBCharacteristic *)cp_advertisingInterval{
    return objc_getAssociatedObject(self, &cp_advertisingInterval);
}

- (CBCharacteristic *)cp_radioTxPower{
    return objc_getAssociatedObject(self, &cp_radioTxPower);
}

- (CBCharacteristic *)cp_advertisedTxPower{
    return objc_getAssociatedObject(self, &cp_advertisedTxPower);
}

- (CBCharacteristic *)cp_lockState{
    return objc_getAssociatedObject(self, &cp_lockState);
}

- (CBCharacteristic *)cp_unlock{
    return objc_getAssociatedObject(self, &cp_unlock);
}

- (CBCharacteristic *)cp_advSlotData{
    return objc_getAssociatedObject(self, &cp_advSlotData);
}

- (CBCharacteristic *)cp_factoryReset{
    return objc_getAssociatedObject(self, &cp_factoryReset);
}

- (CBCharacteristic *)cp_remainConnectable{
    return objc_getAssociatedObject(self, &cp_remainConnectable);
}

- (CBCharacteristic *)cp_deviceType {
    return objc_getAssociatedObject(self, &cp_deviceTypeKey);
}

- (CBCharacteristic *)cp_slotType {
    return objc_getAssociatedObject(self, &cp_slotTypeKey);
}

- (CBCharacteristic *)cp_disconnectListen {
    return objc_getAssociatedObject(self, &cp_disconnectListenKey);
}

- (CBCharacteristic *)cp_voltage{
    return objc_getAssociatedObject(self, &cp_voltage);
}

- (CBCharacteristic *)cp_threeSensor {
    return objc_getAssociatedObject(self, &cp_threeSensorKey);
}

- (CBCharacteristic *)cp_temperatureHumidity {
    return objc_getAssociatedObject(self, &cp_temperatureHumidityKey);
}

- (CBCharacteristic *)cp_hallSensor {
    return objc_getAssociatedObject(self, &cp_hallSensorKey);
}

- (CBCharacteristic *)cp_batteryHistory {
    return objc_getAssociatedObject(self, &cp_batteryHistoryKey);
}

- (CBCharacteristic *)cp_tofData {
    return objc_getAssociatedObject(self, &cp_tofDataKey);
}

- (CBCharacteristic *)cp_temperature {
    return objc_getAssociatedObject(self, &cp_temperatureKey);
}

- (CBCharacteristic *)cp_waterLeakage {
    return objc_getAssociatedObject(self, &cp_waterLeakageKey);
}

- (CBCharacteristic *)cp_customWrite{
    return objc_getAssociatedObject(self, &cp_customWrite);
}

- (CBCharacteristic *)cp_customNotify{
    return objc_getAssociatedObject(self, &cp_customNotify);
}

- (CBCharacteristic *)cp_modeID{
    return objc_getAssociatedObject(self, &cp_modeID);
}

- (CBCharacteristic *)cp_firmware{
    return objc_getAssociatedObject(self, &cp_firmware);
}

- (CBCharacteristic *)cp_productionDate{
    return objc_getAssociatedObject(self, &cp_productionDate);
}

- (CBCharacteristic *)cp_hardware{
    return objc_getAssociatedObject(self, &cp_hardware);
}

- (CBCharacteristic *)cp_software{
    return objc_getAssociatedObject(self, &cp_software);
}

- (CBCharacteristic *)cp_vendor{
    return objc_getAssociatedObject(self, &cp_vendor);
}

#pragma mark - private method
- (void)cp_updateEddystoneCharacteristic:(CBService *)service{
    if (!service) {
        return;
    }
    NSArray *charactList = [service.characteristics mutableCopy];
    for (CBCharacteristic *characteristic in charactList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_activeSlotUUID]]){
            objc_setAssociatedObject(self, &cp_activeSlot, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisingIntervalUUID]]){
            objc_setAssociatedObject(self, &cp_advertisingInterval, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_radioTxPowerUUID]]){
            objc_setAssociatedObject(self, &cp_radioTxPower, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advertisedTxPowerUUID]]){
            objc_setAssociatedObject(self, &cp_advertisedTxPower, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_lockStateUUID]]){
            objc_setAssociatedObject(self, &cp_lockState, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_unlockUUID]]){
            objc_setAssociatedObject(self, &cp_unlock, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_advSlotDataUUID]]){
            objc_setAssociatedObject(self, &cp_advSlotData, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_factoryResetUUID]]){
            objc_setAssociatedObject(self, &cp_factoryReset, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_remainConnectableUUID]]){
            objc_setAssociatedObject(self, &cp_remainConnectable, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)cp_updateCustomCharacteristic:(CBService *)service{
    if (!service) {
        return;
    }
    NSArray *charactList = [service.characteristics mutableCopy];
    for (CBCharacteristic *characteristic in charactList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_writeUUID]]) {
            objc_setAssociatedObject(self, &cp_customWrite, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_notifyUUID]]){
            objc_setAssociatedObject(self, &cp_customNotify, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_deviceTypeUUID]]) {
            objc_setAssociatedObject(self, &cp_deviceTypeKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_slotTypeUUID]]) {
            objc_setAssociatedObject(self, &cp_slotTypeKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_voltageUUID]]) {
            objc_setAssociatedObject(self, &cp_voltage, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_disconnectListenUUID]]) {
            objc_setAssociatedObject(self, &cp_disconnectListenKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_threeSensorUUID]]) {
            objc_setAssociatedObject(self, &cp_threeSensorKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_temperatureHumidityUUID]]) {
            objc_setAssociatedObject(self, &cp_temperatureHumidityKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_hallSensorUUID]]) {
            objc_setAssociatedObject(self, &cp_hallSensorKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_batteryHistoryUUID]]) {
            objc_setAssociatedObject(self, &cp_batteryHistoryKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_tofDataUUID]]) {
            objc_setAssociatedObject(self, &cp_tofDataKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_waterLeakageUUID]]) {
            objc_setAssociatedObject(self, &cp_waterLeakageKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_temperatureUUID]]) {
            objc_setAssociatedObject(self, &cp_temperatureKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)cp_updateDeviceInfoCharacteristic:(CBService *)service{
    if (!service) {
        return;
    }
    NSArray *charactList = [service.characteristics mutableCopy];
    for (CBCharacteristic *characteristic in charactList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_modeIDUUID]]){
            //产品型号
            objc_setAssociatedObject(self, &cp_modeID, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_firmwareUUID]]){
            //固件版本
            objc_setAssociatedObject(self, &cp_firmware, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_productionDateUUID]]){
            //生产日期
            objc_setAssociatedObject(self, &cp_productionDate, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_hardwareUUID]]){
            //硬件版本
            objc_setAssociatedObject(self, &cp_hardware, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_softwareUUID]]){
            //软件版本
            objc_setAssociatedObject(self, &cp_software, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cp_vendorUUID]]){
            //厂商自定义
            objc_setAssociatedObject(self, &cp_vendor, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (BOOL)cp_serviceSuccess{
    if (!self.cp_activeSlot || !self.cp_advertisingInterval
        || !self.cp_radioTxPower || !self.cp_advertisedTxPower || !self.cp_lockState
        || !self.cp_unlock || !self.cp_advSlotData || !self.cp_factoryReset) {
        return NO;
    }
    return YES;
}

- (BOOL)cp_customServiceSuccess{
    if (!self.cp_customNotify || !self.cp_customWrite || !self.cp_deviceType || !self.cp_slotType || !self.cp_disconnectListen || !self.cp_voltage) {
        return NO;
    }
    return YES;
}

- (BOOL)cp_deviceInfoServiceSuccess{
    if (!self.cp_vendor || !self.cp_modeID || !self.cp_hardware || !self.cp_firmware || !self.cp_software
        || !self.cp_productionDate) {
        return NO;
    }
    return YES;
}

@end
