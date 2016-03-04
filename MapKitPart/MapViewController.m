//
//  MapViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"
#import "HYAnnotation.h"

@interface MapViewController ()<MKMapViewDelegate>

{
    CLLocationDegrees _latitudeDelta ;
    CLLocationDegrees _longitudeDelta ;
}

@property (nonatomic, strong) MKMapView *mapView ;

@property (nonatomic, strong) UIButton  *backButton ;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地图";
    _latitudeDelta = 0.1 ;
    _longitudeDelta = 0.1 ;
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    // 设置代理
    _mapView.delegate = self ;
    // 设置跟踪用户的模式
    _mapView.userTrackingMode = MKUserTrackingModeFollow ;
    // 设置地图类型 <标准地图,卫星地图,混合地图>
    _mapView.mapType = MKMapTypeStandard ;
    [self.view addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"btn_map_locate"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView.mas_left).offset(15);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60.f, 60.f));
    }];
}

#pragma mark
#pragma mark --- 回到用户起始的位置
/**
 *  回到用户起始的位置
 */
- (void)backToUserLocation
{
    CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate ;
    MKCoordinateSpan span = MKCoordinateSpanMake(_latitudeDelta, _longitudeDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span) ;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark
#pragma mark --- MKMapView Delegate Method

/**
 *  定位到用户的位置会调用此方法
 *
 *  @param userLocation 用户位置的大头针模型
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 设置mapView的显示位置
//    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    // 设置mapView的显示区域
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [mapView setRegion:region animated:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) return ;
        
        CLPlacemark *pm = [placemarks firstObject];
        if (pm.locality) {
            userLocation.title = pm.locality ;
        }else{
            userLocation.title = pm.administrativeArea;
        }
        userLocation.subtitle = pm.name ;
    }];
}
/**
 *  用户地图显示的区域发生变化时调用
 *
 *  记录下用户span的变化<比例尺,显示范围的大小,越小越精确>
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKCoordinateRegion region = mapView.region ;
//    CLLocationCoordinate2D center = region.center ;
    MKCoordinateSpan span = region.span ;
    _latitudeDelta = span.latitudeDelta ;
    _longitudeDelta = span.longitudeDelta ;
}
@end
