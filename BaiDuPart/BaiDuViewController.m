//
//  BaiDuViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "BaiDuViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>

@interface BaiDuViewController ()<BMKMapViewDelegate>

@property (nonatomic, strong) BMKMapView *mapView ;

@end

@implementation BaiDuViewController

#pragma mark
#pragma mark --- viewController lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self ;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"百度地图";
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self ;
    _mapView.mapType = BMKMapTypeStandard ;
    _mapView.userTrackingMode = BMKUserTrackingModeNone ;
    _mapView.trafficEnabled = YES ;
    [self.view addSubview:_mapView];
}

#pragma mark
#pragma mark --- 销毁对象, 释放资源

-(void)dealloc
{
    if (_mapView) {
        _mapView = nil ;
    }
}

@end
