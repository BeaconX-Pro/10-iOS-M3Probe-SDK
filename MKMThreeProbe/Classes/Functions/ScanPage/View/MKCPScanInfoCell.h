//
//  MKCPScanInfoCell.h
//  MKMThreeProbe_Example
//
//  Created by aa on 2024/1/11.
//  Copyright © 2024 lovexiaoxia. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@class MKCPScanInfoCellModel;
@protocol MKCPScanInfoCellDelegate <NSObject>

- (void)cp_scanInfoCell_connect:(CBPeripheral *)peripheral;

@end

@interface MKCPScanInfoCell : MKBaseCell

@property (nonatomic, weak)id <MKCPScanInfoCellDelegate>delegate;

@property (nonatomic, strong)MKCPScanInfoCellModel *dataModel;

+ (MKCPScanInfoCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
