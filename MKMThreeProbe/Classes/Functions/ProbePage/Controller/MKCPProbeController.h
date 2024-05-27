//
//  MKCPProbeController.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_cp_probeControllerType) {
    mk_cp_probeControllerType_temperature,
    mk_cp_probeControllerType_th,
    mk_cp_probeControllerType_water,
};

@interface MKCPProbeController : MKBaseViewController

@property (nonatomic, assign)mk_cp_probeControllerType type;

@end

NS_ASSUME_NONNULL_END
