//
//  MKCPInterface+MKCPConfig.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKCPInterface.h"

#import "MKCPCentralManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Target SLOT numbers(enum)，slot0~slot4
 */
typedef NS_ENUM(NSInteger, mk_cp_activeSlotNo) {
    mk_cp_activeSlot1,//SLOT 0
    mk_cp_activeSlot2,//SLOT 1
    mk_cp_activeSlot3,//SLOT 2
    mk_cp_activeSlot4,//SLOT 3
    mk_cp_activeSlot5,//SLOT 4
    mk_cp_activeSlot6,//SLOT 5
};
typedef NS_ENUM(NSInteger, mk_cp_slotRadioTxPower) {
    mk_cp_slotRadioTxPowerNeg40dBm,   //-40dBm
    mk_cp_slotRadioTxPowerNeg20dBm,   //-20dBm
    mk_cp_slotRadioTxPowerNeg16dBm,   //-16dBm
    mk_cp_slotRadioTxPowerNeg12dBm,   //-12dBm
    mk_cp_slotRadioTxPowerNeg8dBm,    //-8dBm
    mk_cp_slotRadioTxPowerNeg4dBm,    //-4dBm
    mk_cp_slotRadioTxPower0dBm,       //0dBm
    mk_cp_slotRadioTxPower3dBm,       //3dBm
    mk_cp_slotRadioTxPower4dBm,       //4dBm 
};
typedef NS_ENUM(NSInteger, mk_cp_urlHeaderType) {
    mk_cp_urlHeaderType1,             //http://www.
    mk_cp_urlHeaderType2,             //https://www.
    mk_cp_urlHeaderType3,             //http://
    mk_cp_urlHeaderType4,             //https://
};

typedef NS_ENUM(NSInteger, mk_cp_threeAxisDataRate) {
    mk_cp_threeAxisDataRate1hz,           //1hz
    mk_cp_threeAxisDataRate10hz,          //10hz
    mk_cp_threeAxisDataRate25hz,          //25hz
    mk_cp_threeAxisDataRate50hz,          //50hz
    mk_cp_threeAxisDataRate100hz          //100hz
};

typedef NS_ENUM(NSInteger, mk_cp_threeAxisDataAG) {
    mk_cp_threeAxisDataAG0,               //±2g
    mk_cp_threeAxisDataAG1,               //±4g
    mk_cp_threeAxisDataAG2,               //±8g
    mk_cp_threeAxisDataAG3                //±16g
};

@interface MKCPInterface (MKCPConfig)

/**
 Modifying connection password.Only if the device’s LockState is in UNLOCKED state, the password can be modified.
 
 @param newPassword New password, 16 characters
 @param originalPassword Old password, 16 characters
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configNewPassword:(NSString *)newPassword
             originalPassword:(NSString *)originalPassword
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Resetting to factory state (RESET).NOTE:When resetting the device, the connection password will not be restored which shall remain set to its current value.

 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_factoryDataResetWithSucBlock:(void (^)(id returnData))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Setting lockState

 @param lockState MKCPLockState
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configLockState:(mk_cp_lockState)lockState
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Setting device power off

 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configPowerOffWithSucBlock:(void (^)(id returnData))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Setting device’s connection status.
 NOTE: Be careful to set device’s connection statue .Once the device is set to not connectable, it may not be connected, and other parameters cannot be configured.
 
 @param connectEnable YES：Connectable，NO：Not Connectable
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configConnectStatus:(BOOL)connectEnable
                       sucBlock:(void (^)(id returnData))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;
/**
 MokoBeaconX provides up to 6 SLOTs for users to configure advertisement frame. Before configering the SLOT’s parameter， you should switch the SLOT to target SLOT fristly; otherwise the configuration is only for the currently active SLOT.

 @param slotNo Target SLOT number to switch to
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configActiveSlot:(mk_cp_activeSlotNo)slotNo
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Setting Advertised Tx Power(RSSI@0m, only for eddystone frame).Advertised Tx Power is different for each SLOT. Before setting the target SLOT’s Advertised Tx Power, you should switch the SLOT to target SLOT(Please refer to ，setEddystoneActiveSlot:sucBlock:failedBlock:); otherwise the Advertised Tx Power set is only for the currently active SLOT.
 
 @param advTxPower Advertised Tx Power, range from -100dBm to +20dBm
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configAdvTxPower:(NSInteger)advTxPower
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Setting Radio Tx Power.Radio Tx Power is different for each SLOT. Before setting the target SLOT’s Radio Tx Power, you should switch the SLOT to target SLOT(Please refer to ，setEddystoneActiveSlot:sucBlock:failedBlock:); otherwise the Radio Tx Power set is only for the currently active SLOT.

 @param power power
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configRadioTxPower:(mk_cp_slotRadioTxPower )power
                      sucBlock:(void (^)(id returnData))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Setting the advertising interval of the current SLOT

 @param interval Advertising interval, unit: 100ms, range: 1~100
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configAdvInterval:(NSInteger)interval
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Setting Device Name

 @param deviceName deviceName，1~10 characters
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configDeviceInfoAdvDataWithDeviceName:(NSString *)deviceName
                                         sucBlock:(void (^)(id returnData))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Setting the sampling rate, scale and sensitivity of the 3-axis accelerometer sensor

 @param dataRate sampling rate
 @param acceleration scale
 @param sensitivity The sensitivity of the device to move, the greater the value, the slower it is. 1~255
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configThreeAxisDataParams:(mk_cp_threeAxisDataRate)dataRate
                         acceleration:(mk_cp_threeAxisDataAG)acceleration
                          sensitivity:(NSInteger)sensitivity
                             sucBlock:(void (^)(id returnData))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Setting the temperature and humidity sampling rate

 @param rate Sampling rate, the unit is S, that is, how many seconds to sample the temperature and humidity data, 1s~65535s
 @param sucBlock success callback
 @param failedBlock failed callback
 */
+ (void)cp_configHTSamplingRate:(NSInteger)rate
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Setting whether the device can be shut down using the button.
/// note:The device whose production date must be after 2021.01.01 can support this instruction.
/// @param isOn isOn
/// @param sucBlock success callback
/// @param failedBlock failed callback
+ (void)cp_configButtonPowerStatus:(BOOL)isOn
                           sucBlock:(void (^)(id returnData))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

/// Water leakage detection interval.
/// @param interval 1s~86400s
/// @param sucBlock success callback
/// @param failedBlock failed callback
+ (void)cp_configWaterLeakageDetectionInterval:(NSInteger)interval 
                                      sucBlock:(void (^)(id returnData))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

+ (void)cp_configLEDTriggerStatus:(BOOL)isOn
                          sucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

+ (void)cp_configResetBeaconByButtonStatus:(BOOL)isOn
                                   sucBlock:(void (^)(id returnData))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
