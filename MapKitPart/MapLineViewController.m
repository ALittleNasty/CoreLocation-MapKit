//
//  MapLineViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "MapLineViewController.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"

@interface MapLineViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView ;

@end

@implementation MapLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"路线绘制";
    
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
}

#pragma mark
#pragma mark --- 搜索路线

- (void)searchRoteWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate andEndCoordinate:(CLLocationCoordinate2D)endCoordinate
{
//    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(31.234, 121.452);
    
    MKPlacemark *fromPM = [[MKPlacemark alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
    
    MKPlacemark *toPM = [[MKPlacemark alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
    
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPM];
    MKMapItem *toItem = [[MKMapItem alloc] initWithPlacemark:toPM];
    
    [self findDirectionsFrom:fromItem to:toItem];
}

- (void)findDirectionsFrom:(MKMapItem *)fromItem to:(MKMapItem *)toItem
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem ;
    request.destination = toItem ;
    request.requestsAlternateRoutes = YES ;
    /**
     MKDirectionsTransportTypeAutomobile = 1 << 0,  //驾车
     MKDirectionsTransportTypeWalking = 1 << 1,     //步行
     MKDirectionsTransportTypeTransit NS_ENUM_AVAILABLE(10_11, 9_0) = 1 << 2, // Only supported for ETA calculations
     MKDirectionsTransportTypeAny = 0x0FFFFFFF
     */
    request.transportType = MKDirectionsTransportTypeAutomobile ;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) return ;
        MKRoute *route = response.routes[0] ;
        
        [self.mapView addOverlay:route.polyline];
    }];
}

#pragma mark
#pragma mark --- mapView delegate

/**
 *  用户更新位置就会调用
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(31.234, 121.452);
    [self searchRoteWithStartCoordinate:userLocation.location.coordinate andEndCoordinate:toCoordinate];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    render.strokeColor = [UIColor redColor];
    
    render.lineWidth = 4.f ;
    
    return render ;
}

@end
