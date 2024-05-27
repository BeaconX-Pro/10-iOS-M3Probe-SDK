//
//  MKCPSensorCell.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/24.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPSensorCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *detailMsg;

@property (nonatomic, strong)UIImage *icon;

@end

@interface MKCPSensorCell : MKBaseCell

@property (nonatomic, strong)MKCPSensorCellModel *dataModel;

+ (MKCPSensorCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
