//
//  MKCPPeripheral.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "CBPeripheral+MKCPAdd.h"
#import "MKCPService.h"

@interface MKCPPeripheral ()

@property (nonatomic, strong)CBPeripheral *peripheral;

@end

@implementation MKCPPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)discoverServices {
    NSArray *services = @[[CBUUID UUIDWithString:cp_configServiceUUID],  //bxp通用配置服务
                          [CBUUID UUIDWithString:cp_customServiceUUID],  //custom配置服务
                          [CBUUID UUIDWithString:cp_deviceServiceUUID]]; //设备信息服务
    [self.peripheral discoverServices:services];
}

- (void)discoverCharacteristics {
    for (CBService *service in self.peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_configServiceUUID]]) {
            NSArray *list = @[[CBUUID UUIDWithString:cp_activeSlotUUID],
                              [CBUUID UUIDWithString:cp_advertisingIntervalUUID],
                              [CBUUID UUIDWithString:cp_radioTxPowerUUID],
                              [CBUUID UUIDWithString:cp_advertisedTxPowerUUID],
                              [CBUUID UUIDWithString:cp_lockStateUUID],
                              [CBUUID UUIDWithString:cp_unlockUUID],
                              [CBUUID UUIDWithString:cp_advSlotDataUUID],
                              [CBUUID UUIDWithString:cp_factoryResetUUID],
                              [CBUUID UUIDWithString:cp_remainConnectableUUID]];
            [self.peripheral discoverCharacteristics:list forService:service];
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_customServiceUUID]]) {
            NSArray *characteristics = @[[CBUUID UUIDWithString:cp_writeUUID],
                                         [CBUUID UUIDWithString:cp_notifyUUID],
                                         [CBUUID UUIDWithString:cp_deviceTypeUUID],
                                         [CBUUID UUIDWithString:cp_slotTypeUUID],
                                         [CBUUID UUIDWithString:cp_voltageUUID],
                                         [CBUUID UUIDWithString:cp_disconnectListenUUID],
                                         [CBUUID UUIDWithString:cp_threeSensorUUID],
                                         [CBUUID UUIDWithString:cp_temperatureHumidityUUID],
                                         [CBUUID UUIDWithString:cp_hallSensorUUID],
                                         [CBUUID UUIDWithString:cp_batteryHistoryUUID],
                                         [CBUUID UUIDWithString:cp_tofDataUUID],
                                         [CBUUID UUIDWithString:cp_waterLeakageUUID],
                                         [CBUUID UUIDWithString:cp_temperatureUUID]];
            [self.peripheral discoverCharacteristics:characteristics forService:service];
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:cp_deviceServiceUUID]]) {
            NSArray *characteristics = @[[CBUUID UUIDWithString:cp_modeIDUUID],
                                         [CBUUID UUIDWithString:cp_firmwareUUID],
                                         [CBUUID UUIDWithString:cp_productionDateUUID],
                                         [CBUUID UUIDWithString:cp_hardwareUUID],
                                         [CBUUID UUIDWithString:cp_softwareUUID],
                                         [CBUUID UUIDWithString:cp_vendorUUID]];
            [self.peripheral discoverCharacteristics:characteristics forService:service];
        }
    }
}

- (void)updateCharacterWithService:(CBService *)service {
    [self.peripheral cp_updateCharacterWithService:service];
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    [self.peripheral cp_updateCurrentNotifySuccess:characteristic];
}

- (BOOL)connectSuccess {
    return [self.peripheral cp_connectSuccess];
}

- (void)setNil {
    [self.peripheral cp_setNil];
}

@end
