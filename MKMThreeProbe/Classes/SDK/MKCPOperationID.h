
typedef NS_ENUM(NSInteger, mk_cp_taskOperationID) {
    mk_cp_defaultTaskOperationID,
    
    mk_cp_taskReadVendorOperation,                     //读取厂商信息
    mk_cp_taskReadModeIDOperation,                     //读取产品型号信息
    mk_cp_taskReadProductionDateOperation,             //读取生产日期
    mk_cp_taskReadHardwareOperation,                   //读取硬件信息
    mk_cp_taskReadFirmwareOperation,                   //读取固件信息
    mk_cp_taskReadSoftwareOperation,                   //读取软件版本
    
    mk_cp_taskReadActiveSlotOperation,                 //获取activeSlot数据
    mk_cp_taskReadAdvertisingIntervalOperation,        //获取广播间隔
    mk_cp_taskReadRadioTxPowerOperation,               //获取发射功率
    mk_cp_taskReadAdvTxPowerOperation,                 //获取广播功率
    mk_cp_taskReadLockStateOperation,                  //获取eddystone的lock状态
    mk_cp_taskReadUnlockOperation,
    mk_cp_taskReadAdvSlotDataOperation,
    mk_cp_taskConfigActiveSlotOperation,                 //设置activeSlot数据
    mk_cp_taskConfigAdvertisingIntervalOperation,        //设置广播间隔
    mk_cp_taskConfigRadioTxPowerOperation,               //设置发射功率
    mk_cp_taskConfigAdvTxPowerOperation,                 //设置广播功率
    mk_cp_taskConfigLockStateOperation,                  //设置eddystone的lock状态
    mk_cp_taskConfigUnlockOperation,
    mk_cp_taskConfigAdvSlotDataOperation,
    mk_cp_taskConfigFactoryResetOperation,
    
    
    mk_cp_taskReadMacAddressOperation,                   //获取eddystone的mac地址
    mk_cp_taskReadThreeAxisParamsOperation,          //读取三轴传感器参数
    mk_cp_taskReadHTSamplingRateOperation,           //读取温湿度采样率
    mk_cp_taskConfigPowerOffOperation,                    //关机命令
    mk_cp_taskReadButtonPowerStatusOperation,      //读取按键关机状态
    mk_cp_taskReadWaterLeakageDetectionIntervalOperation,   //读取漏水状态采集间隔
    mk_cp_taskConfigThreeAxisParamsOperation,           //设置三轴传感器参数
    mk_cp_taskConfigHTSamplingRateOperation,           //设置温湿度采样率
    mk_cp_taskConfigButtonPowerStatusOperation,    //设置按键关机状态
    mk_cp_taskConfigWaterLeakageDetectionIntervalOperation, //配置漏水状态采集间隔
    mk_cp_taskReadLEDTriggerStatusOperation,           //读取LED触发提醒状态
    mk_cp_taskReadResetBeaconByButtonStatusOperation,  //读取设备是否可以按键开关机
    mk_cp_taskConfigLEDTriggerStatusOperation,         //设置LED触发提醒状态
    mk_cp_taskConfigResetBeaconByButtonStatusOperation,    //设置设备是否可以按键开关机
    
    
    
    mk_cp_taskReadConnectEnableOperation,                //获取eddystone的可连接状态
    mk_cp_taskConfigConnectEnableOperation,              //设置eddystone的可连接状态
    
    mk_cp_taskReadBatteryOperation,                      //读取battery
    mk_cp_taskReadDeviceTypeOperation,               //读取设备类型
};
