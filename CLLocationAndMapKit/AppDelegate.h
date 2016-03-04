//
//  AppDelegate.h
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/17.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

#define BaiDuMapKey @"XOvL1D3rn3Gd3CGVHzKn4bze"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) BMKLocationService *locService ;

@property (nonatomic) double latitude ;
@property (nonatomic) double longitude ;

@end

