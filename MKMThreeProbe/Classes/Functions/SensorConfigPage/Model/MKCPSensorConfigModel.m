//
//  MKCPSensorConfigModel.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import "MKCPSensorConfigModel.h"

#import "MKMacroDefines.h"

#import "MKCPInterface.h"
#import "MKCPInterface+MKCPConfig.h"

@interface MKCPSensorConfigModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKCPSensorConfigModel

- (void)readWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self readHTInterval]) {
            [self operationFailedBlockWithMsg:@"Read HT Interval Error" block:failedBlock];
            return;
        }
        if (![self readWaterInterval]) {
            [self operationFailedBlockWithMsg:@"Read Water Interval Error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (void)configWithSucBlock:(void (^)(void))sucBlock failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.readQueue, ^{
        if (![self validParams]) {
            [self operationFailedBlockWithMsg:@"Params error" block:failedBlock];
            return;
        }
        
        if (![self configHTInterval]) {
            [self operationFailedBlockWithMsg:@"Config HT Interval Error" block:failedBlock];
            return;
        }
        if (![self configWaterInterval]) {
            [self operationFailedBlockWithMsg:@"Config Water Interval Error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

#pragma mark - interface

- (BOOL)readHTInterval {
    __block BOOL success = NO;
    [MKCPInterface cp_readHTSamplingRateWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.thSamplingInterval = returnData[@"result"][@"samplingRate"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configHTInterval {
    __block BOOL success = NO;
    [MKCPInterface cp_configHTSamplingRate:[self.thSamplingInterval integerValue] sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readWaterInterval {
    __block BOOL success = NO;
    [MKCPInterface cp_readWaterLeakageDetectionIntervalWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.waterInterval = returnData[@"result"][@"interval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWaterInterval {
    __block BOOL success = NO;
    [MKCPInterface cp_configWaterLeakageDetectionInterval:[self.waterInterval integerValue] sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"acceleration"
                                                    code:-999
                                                userInfo:@{@"errorInfo":msg}];
        block(error);
    });
}

- (BOOL)validParams {
    if (!ValidStr(self.thSamplingInterval) || [self.thSamplingInterval integerValue] < 1 || [self.thSamplingInterval integerValue] > 65535) {
        return NO;
    }
    
    if (!ValidStr(self.waterInterval) || [self.waterInterval integerValue] < 1 || [self.waterInterval integerValue] > 86400) {
        return NO;
    }

    
    return YES;
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("accelerationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
