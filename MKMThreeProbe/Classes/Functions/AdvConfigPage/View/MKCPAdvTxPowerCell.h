//
//  MKCPAdvTxPowerCell.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/5/27.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCPAdvTxPowerCellModel : NSObject

/*
 0,   //RadioTxPower:-40dBm
 1,   //-20dBm
 2,   //-16dBm
 3,   //-12dBm
 4,    //-8dBm
 5,    //-4dBm
 6,       //0dBm
 7,       //3dBm
 8,       //4dBm
 */
@property (nonatomic, assign)NSInteger txPowerValue;

@end

@protocol MKCPAdvTxPowerCellDelegate <NSObject>

/*
 0,   //RadioTxPower:-40dBm
 1,   //-20dBm
 2,   //-16dBm
 3,   //-12dBm
 4,    //-8dBm
 5,    //-4dBm
 6,       //0dBm
 7,       //3dBm
 8,       //4dBm
 */
- (void)cp_txPowerValueChanged:(NSInteger)txPower;

@end

@interface MKCPAdvTxPowerCell : MKBaseCell

@property (nonatomic, weak)id <MKCPAdvTxPowerCellDelegate>delegate;

@property (nonatomic, strong)MKCPAdvTxPowerCellModel *dataModel;

+ (MKCPAdvTxPowerCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
