//
//  Target_M3Probe_Module.m
//  MKMThreeProbe_Example
//
//  Created by aa on 2021/3/14.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "Target_M3Probe_Module.h"

#import "MKCPScanViewController.h"

@implementation Target_M3Probe_Module

- (UIViewController *)Action_M3Probe_Module_ScanController:(NSDictionary *)params {
    return [[MKCPScanViewController alloc] init];
}

@end
