//
//  MKCPProbeValueView.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPProbeValueView : UIView

@property (nonatomic, copy)NSString *titleMsg;

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, strong)UIImage *leftIcon;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, copy)NSString *unit;

@end

NS_ASSUME_NONNULL_END
