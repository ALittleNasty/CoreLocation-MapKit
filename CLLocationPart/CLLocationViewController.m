//
//  CLLocationViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/17.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "CLLocationViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface CLLocationViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager ;

@end

@implementation CLLocationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"定位";
    
    //开始定位
    [self.mananger startUpdatingLocation];
    
    
    [self calculateDistance];
}

#pragma mark
#pragma mark --- 计算两个坐标之间的距离
/**
 *  计算两个坐标之间的距离
 */
- (void)calculateDistance
{
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:23.33 longitude:112.23];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:24.34 longitude:112.23];
    
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    
    NSLog(@"distance --- %f",distance);
}

#pragma mark
#pragma mark --- CLLocationManager Delegate Method
/**
 *  定位到用户的位置就会调用 , 会频繁调用
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //    NSLog(@"%s",__func__);  7265231C-39B4-402C-89E1-16167C4CC990
    
    // 拿到用户最新的地理位置
    CLLocation *location = [locations lastObject];
    
    NSLog(@"latitude -- %f, longtitude---%f",location.coordinate.latitude, location.coordinate.longitude) ;
    
    //定位成功后就停止 , 频繁调用会很耗电
    [manager stopUpdatingLocation];
}

#pragma mark
#pragma mark --- 懒加载 mananger

-(CLLocationManager *)mananger
{
    if (_manager == nil) {
        //1.创建地图管理对象
        _manager = [[CLLocationManager alloc] init];
        
        //2.设置代理
        _manager.delegate = self ;
        
        //3.隔多少米再次定位
        _manager.distanceFilter = 10 ;
        
        //4.精度范围
        _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters ;
    }
    return _manager ;
}

@end
