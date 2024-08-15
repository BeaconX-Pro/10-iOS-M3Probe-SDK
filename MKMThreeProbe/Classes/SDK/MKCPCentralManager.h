//
//  MKCPCentralManager.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MKBaseBleModule/MKBLEBaseDataProtocol.h>

#import "MKCPOperationID.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCentralManager,CBPeripheral;
@class MKCPBaseBeacon;

extern NSString *const mk_cp_receiveThreeAxisAccelerometerDataNotification;
extern NSString *const mk_cp_receiveHTDataNotification;
extern NSString *const mk_cp_receiveTemperatureDataNotification;
extern NSString *const mk_cp_receiveWaterLeakageDetectionDataNotification;

/*
 After connecting the device, if no password is entered within one minute, it returns 0x00. After successful password change, it returns 0x01. Factory reset of the device,it returns 0x02.
 */
extern NSString *const mk_cp_deviceDisconnectTypeNotification;

//Notification of device connection status changes.
extern NSString *const mk_cp_peripheralConnectStateChangedNotification;

//Notification of changes in the status of the Bluetooth Center.
extern NSString *const mk_cp_centralManagerStateChangedNotification;

//Notification of changes in the status of the Eddystone Lock State.
extern NSString *const mk_cp_peripheralLockStateChangedNotification;

typedef NS_ENUM(NSInteger, mk_cp_centralManagerStatus) {
    mk_cp_centralManagerStatusUnable,                           //不可用
    mk_cp_centralManagerStatusEnable,                           //可用状态
};

typedef NS_ENUM(NSInteger, mk_cp_centralConnectStatus) {
    mk_cp_centralConnectStatusUnknow,                                           //未知状态
    mk_cp_centralConnectStatusConnecting,                                       //正在连接
    mk_cp_centralConnectStatusConnected,                                        //连接成功
    mk_cp_centralConnectStatusConnectedFailed,                                  //连接失败
    mk_cp_centralConnectStatusDisconnect,
};

typedef NS_ENUM(NSInteger, mk_cp_lockState) {
    mk_cp_lockStateUnknow,
    mk_cp_lockStateLock,
    mk_cp_lockStateOpen,
    mk_cp_lockStateUnlockAutoMaticRelockDisabled,
};

@protocol mk_cp_centralManagerScanDelegate <NSObject>

/// Scan to new device.
/// @param devicePara devicePara
- (void)mk_cp_receiveDevicePara:(NSDictionary *)devicePara;

@optional

/// Starts scanning equipment.
- (void)mk_cp_startScan;

/// Stops scanning equipment.
- (void)mk_cp_stopScan;

@end

@interface MKCPCentralManager : NSObject<MKBLEBaseCentralManagerProtocol>

@property (nonatomic, weak)id <mk_cp_centralManagerScanDelegate>delegate;

/// Current connection status
@property (nonatomic, assign, readonly)mk_cp_centralConnectStatus connectState;

@property (nonatomic, assign, readonly)mk_cp_lockState lockState;

+ (MKCPCentralManager *)shared;

/// Destroy the MKCPCentralManager singleton and the MKBLEBaseCentralManager singleton. After the dfu upgrade, you need to destroy these two and then reinitialize.
+ (void)sharedDealloc;

/// Destroy the MKCPCentralManager singleton and remove the manager list of MKBLEBaseCentralManager.
+ (void)removeFromCentralList;

- (nonnull CBCentralManager *)centralManager;

/// Currently connected devices
- (nullable CBPeripheral *)peripheral;

/// Current Bluetooth center status
- (mk_cp_centralManagerStatus )centralStatus;

/// Bluetooth Center starts scanning
- (void)startScan;

/// Bluetooth center stops scanning
- (void)stopScan;

/// Interface of connection
/// @param peripheral peripheral
/// @param password password,16 characters.
/// @param progressBlock progress callback
/// @param sucBlock succeed callback
/// @param failedBlock failed callback
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
                 password:(nonnull NSString *)password
            progressBlock:(void (^)(float progress))progressBlock
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Gets the current lockstate of the device，00(locked)、02(UnlockAutoMaticRelockDisabled)
 
 @param peripheral peripheral
 @param sucBlock read success callback
 @param failedBlock read failed callback
 */
- (void)readLockStateWithPeripheral:(nonnull CBPeripheral *)peripheral
                           sucBlock:(void (^)(NSString *lockState))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Interface of connection, if lockstate is 02, no password connection is required, otherwise an error will be reported.
 
 @param peripheral peripheral
 @param progressBlock progress callback
 @param sucBlock Connection succeed callback
 @param failedBlock Connection failed callback
 */
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral
            progressBlock:(void (^)(float progress))progressBlock
                 sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

- (void)disconnect;

/**
 Add a design task (app - > peripheral) to the queue
 
 @param operationID operationID
 @param commandData Communication data
 @param characteristic characteristic
 @param sucBlock Communication succeed callback
 @param failedBlock Communication failed callback
 */
- (void)addTaskWithTaskID:(mk_cp_taskOperationID)operationID
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Add a reading task (app - > peripheral) to the queue
 
 @param operationID operationID
 @param characteristic characteristic
 @param sucBlock Communication succeed callback
 @param failedBlock Communication failed callback
 */
- (void)addReadTaskWithTaskID:(mk_cp_taskOperationID)operationID
               characteristic:(CBCharacteristic *)characteristic
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Whether to monitor 3-axis accelerometer sensor data

 @param notify BOOL
 @return result
 */
- (BOOL)notifyThreeAxisAcceleration:(BOOL)notify;

/**
 Whether to monitor temperature and humidity sensor data

 @param notify BOOL
 @return result
 */
- (BOOL)notifyTHData:(BOOL)notify;

/**
 Whether to monitor temperature sensor data

 @param notify BOOL
 @return result
 */
- (BOOL)notifyTemperatureData:(BOOL)notify;

/**
 Whether to monitor water leakage detection data

 @param notify BOOL
 @return result
 */
- (BOOL)notifyWaterLeakageDetectionData:(BOOL)notify;

@end

NS_ASSUME_NONNULL_END
