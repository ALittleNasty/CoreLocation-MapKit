//
//  AppDelegate.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/17.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>


BMKMapManager* _mapManager;
@interface AppDelegate ()<BMKLocationServiceDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:BaiDuMapKey generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }else{
        NSLog(@"manager start success");
        
        _locService = [[BMKLocationService alloc] init];
        _locService.delegate = self ;
        [_locService startUserLocationService];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark --- Baidu SDK method
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

#pragma mark
#pragma mark --- BMKLocationServiceDelegate method

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"location service locate success");
    
    CLLocationCoordinate2D center = userLocation.location.coordinate ;
    
    self.latitude = center.latitude ;
    self.longitude = center.longitude ;
    
    NSLog(@"用户位置: 纬度:%f , 经度:%f",self.latitude,self.longitude);
    
    [self.locService stopUserLocationService];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location service failed with error:%@",error);
    
    self.latitude = 0.0 ;
    self.longitude = 0.0 ;
}

@end
