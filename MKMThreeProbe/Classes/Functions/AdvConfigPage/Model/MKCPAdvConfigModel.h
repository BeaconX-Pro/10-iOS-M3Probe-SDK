//
//  MKCPAdvConfigModel.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/27.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPAdvConfigModel : NSObject

@property (nonatomic, copy)NSString *advName;

@property (nonatomic, copy)NSString *interval;

@property (nonatomic, assign)NSInteger txPower;

- (void)readDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

- (void)configDataWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
