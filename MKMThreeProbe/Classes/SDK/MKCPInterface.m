//
//  MKCPInterface.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPInterface.h"

#import "CBPeripheral+MKCPAdd.h"
#import "MKCPCentralManager.h"
#import "MKCPOperationID.h"

#define centralManager [MKCPCentralManager shared]
#define peripheral [MKCPCentralManager shared].peripheral

@implementation MKCPInterface

+ (void)cp_readDeviceTypeWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadDeviceTypeOperation
                           characteristic:peripheral.cp_deviceType
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readMacAddresWithSucBlock:(void (^)(id returnData))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ea200000";
    [centralManager addTaskWithTaskID:mk_cp_taskReadMacAddressOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readModeIDWithSucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadModeIDOperation
                           characteristic:peripheral.cp_modeID
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readSoftwareWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadSoftwareOperation
                           characteristic:peripheral.cp_software
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readFirmwareWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadFirmwareOperation
                           characteristic:peripheral.cp_firmware
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readHardwareWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadHardwareOperation
                           characteristic:peripheral.cp_hardware
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readProductionDateWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadProductionDateOperation
                           characteristic:peripheral.cp_productionDate
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readVendorWithSucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadVendorOperation
                           characteristic:peripheral.cp_vendor
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readBatteryWithSucBlock:(void (^)(id returnData))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadBatteryOperation
                           characteristic:peripheral.cp_voltage
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readConnectEnableStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadConnectEnableOperation
                           characteristic:peripheral.cp_remainConnectable
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readRadioTxPowerWithSucBlock:(void (^)(id returnData))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadRadioTxPowerOperation
                           characteristic:peripheral.cp_radioTxPower
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readAdvDataWithSucBlock:(void (^)(id returnData))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadAdvSlotDataOperation
                           characteristic:peripheral.cp_advSlotData
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readAdvTxPowerWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadAdvTxPowerOperation
                           characteristic:peripheral.cp_advertisedTxPower
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readAdvIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_cp_taskReadAdvertisingIntervalOperation
                           characteristic:peripheral.cp_advertisingInterval
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

+ (void)cp_readThreeAxisDataParamsWithSucBlock:(void (^)(id returnData))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ea210000";
    [centralManager addTaskWithTaskID:mk_cp_taskReadThreeAxisParamsOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readHTSamplingRateWithSucBlock:(void (^)(id returnData))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ea230000";
    [centralManager addTaskWithTaskID:mk_cp_taskReadHTSamplingRateOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readButtonPowerStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ea280000";
    [centralManager addTaskWithTaskID:mk_cp_taskReadButtonPowerStatusOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readWaterLeakageDetectionIntervalWithSucBlock:(void (^)(id returnData))sucBlock
                                             failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ea440000";
    [centralManager addTaskWithTaskID:mk_cp_taskReadWaterLeakageDetectionIntervalOperation
                          commandData:commandString
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readLEDTriggerStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_cp_taskReadLEDTriggerStatusOperation
                          commandData:@"ea470000"
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

+ (void)cp_readResetBeaconByButtonStatusWithSucBlock:(void (^)(id returnData))sucBlock
                                          failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_cp_taskReadResetBeaconByButtonStatusOperation
                          commandData:@"ea480000"
                       characteristic:peripheral.cp_customWrite
                             sucBlock:sucBlock
                          failedBlock:failedBlock];
}

@end
