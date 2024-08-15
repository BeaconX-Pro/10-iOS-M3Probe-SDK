# iOS SDK for M3 Probe product in BeaconX Pro APP Kit Guide

* This SDK support the company's M3 Probe products.

# Design instructions

* We divide the communications between SDK and devices into two stages: Scanning stage, Connection stage.For ease of understanding, let's take a look at the related classes and the relationships between them.

`MKCPCentralManager`：global manager, check system's bluetooth status, listen status changes, the most important is scan and connect to devices;

`MKCPInterface`: When the device is successfully connected, the device data can be read through the interface in `MKCPInterface`;

`MKCPInterface+MKCPConfig.h`: When the device is successfully connected, you can configure the device data through the interface in `MKCPInterface+MKCPConfig.h`;


## Scanning Stage

in this stage, `MKCPCentralManager ` will scan and analyze the advertisement data of PIR devices, `MKCPCentralManager ` will create a dictionary instance for every physical devices, developers can get all advertisement data by its property.


## Connection Stage

Developers can get the lock state of the current device by calling the `readLockStateWithPeripheral:sucBlock:failedBlock:` interface.If the current lock status is 00, you need to enter the connection password and call `connectPeripheral:password:progressBlock:sucBlock:failedBlock` to connect;If the current lock status is 02, it indicates that the current device can log in without password, call `connectPeripheral:progressBlock:sucBlock:failedBlock:` to connect.


# Get Started

### Development environment:

* Xcode9+， due to the DFU and Zip Framework based on Swift4.0, so please use Xcode9 or high version to develop;
* iOS14, we limit the minimum iOS system version to 14.0；

### Import to Project

CocoaPods

SDK is available through [CocoaPods](https://cocoapods.org).To install it, simply add the following line to your Podfile, and then import ` <MKMThreeProbe/MKCPSDK.h>` ：

**pod 'MKMThreeProbe/SDK'**


* <font color=#FF0000 face="黑体">!!!on iOS 10 and above, Apple add authority control of bluetooth, you need add the string to "info.plist" file of your project: Privacy - Bluetooth Peripheral Usage Description - "your description". as the screenshot below.</font>

* <font color=#FF0000 face="黑体">!!! In iOS13 and above, Apple added permission restrictions on Bluetooth APi. You need to add a string to the project's info.plist file: Privacy-Bluetooth Always Usage Description-"Your usage description".</font>


## Start Developing

### Get sharedInstance of Manager

First of all, the developer should get the sharedInstance of Manager:

```
MKCPCentralManager *manager = [MKCPCentralManager shared];
```

#### 1.Start scanning task to find devices around you,please follow the steps below:

* 1.`manager.delegate = self;` //Set the scan delegate and complete the related delegate methods.
* 2.you can start the scanning task in this way:`[manager startScan];`    
* 3.at the sometime, you can stop the scanning task in this way:`[manager stopScan];`

#### 2.Connect to device

* 1.Developers should first read the lock state of the device, which determines whether a connection password is required when connecting to the device.

```
[[MKCPCentralManager shared] readLockStateWithPeripheral:peripheral sucBlock:^(NSString *lockState) {
        if ([lockState isEqualToString:@"00"]) {
            //A password is required to connect to the device.
            return;
        }
        if ([lockState isEqualToString:@"02"]) {
            //No password is required to connect to the current device.
            return;
        }
    } failedBlock:^(NSError *error) {
        //Failed callback
    }];
```

* 2.If the device requires a connection password, the connection method is as follows:

```
[[MKCPCentralManager shared] connectPeripheral:peripheral password:password progressBlock:^(float progress) {
        //progress
    } sucBlock:^(CBPeripheral *peripheral) {
        //Success 
    } failedBlock:^(NSError *error) {
        //Failure
    }];
```

* 3.If the device is connected without password, the connection method is as follows:

```
[[MKCPCentralManager shared] connectPeripheral:peripheral progressBlock:^(float progress) {
        //progress
    } sucBlock:^(CBPeripheral *peripheral) {
        //Success
    } failedBlock:^(NSError *error) {
        //Failure
    }];
```

#### 3.Get State

Through the manager, you can get the current Bluetooth status of the mobile phone, the connection status of the device, and the lock status of the device. If you want to monitor the changes of these three states, you can register the following notifications to achieve:

*  When the Bluetooth status of the mobile phone changes，<font color=#FF0000 face="黑体">`mk_cp_centralManagerStateChangedNotification`</font> will be posted.You can get status in this way:

```
[[MKCPCentralManager shared] centralStatus];
```

*  When the device connection status changes，<font color=#FF0000 face="黑体"> `mk_cp_peripheralConnectStateChangedNotification` </font> will be posted.You can get the status in this way:

```
[MKCPCentralManager shared].connectState;
```

*  When the lock state of the device changes，<font color=#FF0000 face="黑体"> `mk_cp_peripheralLockStateChangedNotification` </font> will be posted.You can get the status in this way: 

```
[MKCPCentralManager shared].lockState;
```

#### 4.Monitor three-axis data.

When the device is connected, the developer can monitor the three-axis data of the device through the following steps:

*  1.Open data monitoring by the following method:

```
[[MKBXPCentralManager shared] notifyThreeAxisAcceleration:YES];
```


*  2.Register for `mk_bxp_receiveThreeAxisAccelerometerDataNotification` notifications to monitor device three-axis data changes.


```

[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAxisDatas:)
                                                 name:mk_bxp_receiveThreeAxisAccelerometerDataNotification
                                               object:nil];
```


```
#pragma mark - Notification
- (void)receiveAxisDatas:(NSNotification *)note {
    NSDictionary *dic = note.userInfo;
    if (!ValidDict(dic)) {
        return;
    }
    NSArray *tempList = dic[@"axisData"];
    if (!ValidArray(tempList)) {
        return;
    }
}
```

#### 5.Monitor temperature and humidity data.

When the device is connected, the developer can monitor the temperature and humidity data of the device through the following steps:

* 1.Open data monitoring by the following method:

```
[[MKBXPCentralManager shared] notifyTHData:YES];
```

* 2.Register for `mk_bxp_receiveHTDataNotification` notifications to monitor device H&T data changes.

```
[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHTDatas:)
                                                 name:mk_bxp_receiveHTDataNotification
                                               object:nil];
```

```
- (void)receiveHTDatas:(NSNotification *)note {
    NSDictionary *dataDic = note.userInfo;
    /*
        @{
        @"temperature":temperature,@"humidity":humidity,
        }
    */
    if (!ValidDict(dataDic)) {
        return;
    }
}
```

#### 6.Monitor temperature data.

When the device is connected, the developer can monitor the temperature data of the device through the following steps:

* 1.Open data monitoring by the following method:

```
[[MKBXPCentralManager shared] notifyTemperatureData:YES];
```

* 2.Register for `mk_cp_receiveTemperatureDataNotification` notifications to monitor device temperature data changes.

```
[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveTemperatureData:)
                                                     name:mk_cp_receiveTemperatureDataNotification
                                                   object:nil];
```

```
- (void)receiveTemperatureData:(NSNotification *)note {
    /*
        @{
            @"temperature":@"10.1"    
        }
    */
    NSDictionary *dataDic = note.userInfo;
}
```


#### 7.Monitor water leakage detection data.

When the device is connected, the developer can monitor the water leakage detection data of the device through the following steps:

* 1.Open data monitoring by the following method:

```
[[MKBXPCentralManager shared] notifyWaterLeakageDetectionData:YES];
```

* 2.Register for `mk_cp_receiveWaterLeakageDetectionDataNotification` notifications to monitor device temperature data changes.

```
[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveWaterData:)
                                                     name:mk_cp_receiveWaterLeakageDetectionDataNotification
                                                   object:nil];
```

```
- (void)receiveWaterData:(NSNotification *)note {
    /*
        @{
            @"leakage":@(YES)
        }
    */
    NSDictionary *dataDic = note.userInfo;
}
```



# Change log

* 2024081501 first version;
