//
//  MKCPConnectManager.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/2/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKCPConnectManager : NSObject

@property (nonatomic, copy)NSString *password;

/// 是否打开了密码验证，当lockState为mk_bxp_lockStateOpen,表明设备打开了密码验证
@property (nonatomic, assign)BOOL passwordVerification;

+ (MKCPConnectManager *)shared;

/// 清除当前所有参数
- (void)clearParams;

- (void)connectPeripheral:(CBPeripheral *)peripheral
                 password:(NSString *)password
            progressBlock:(void (^)(float progress))progressBlock
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
