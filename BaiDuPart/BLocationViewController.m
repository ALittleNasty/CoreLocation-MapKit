//
//  BLocationViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "BLocationViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface BLocationViewController ()<BMKLocationServiceDelegate,BMKMapViewDelegate>

@property (nonatomic, strong) BMKLocationService *locService ;

@property (nonatomic, strong) BMKMapView         *mapView ;

@end

@implementation BLocationViewController

#pragma mark
#pragma mark --- viewController lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self ;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"百度定位";
    
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self ;
    [_locService startUserLocationService];
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self ;
    _mapView.mapType = BMKMapTypeStandard ;
    _mapView.showsUserLocation = NO ;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow ;
    _mapView.showsUserLocation = YES ;
    [self.view addSubview:_mapView];
}
#pragma mark
#pragma mark --- BMKLocationServiceDelegate method

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate ;
    
    BMKCoordinateSpan span ;
    span.latitudeDelta = 0.01 ;
    span.longitudeDelta = 0.01 ;
    
    BMKCoordinateRegion region ;
    region.center = center ;
    region.span = span ;
    
    [_mapView setRegion:region animated:YES];
    
    [_mapView updateLocationData:userLocation];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location service failed with error:%@",error);
}


#pragma mark
#pragma mark --- 销毁对象,释放资源
-(void)dealloc
{
    if (_mapView) {
        _mapView = nil ;
    }
}

@end
