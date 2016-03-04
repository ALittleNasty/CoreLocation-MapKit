//
//  AnnotationViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "AnnotationViewController.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"
#import "HYAnnotation.h"

static NSString *annoIndentifier = @"annotationViewID";
@interface AnnotationViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView ;

@property (nonatomic, strong) UIButton  *annoButton ;

@end

@implementation AnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"大头针";
    
    
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
    
    
    _annoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_annoButton setImage:[UIImage imageNamed:@"btn_map_locate"] forState:UIControlStateNormal];
    [_annoButton addTarget:self action:@selector(addCustomAnnotation) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_annoButton];
    [_annoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView.mas_left).offset(15);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60.f, 60.f));
    }];
}

#pragma mark
#pragma mark --- 添加大头针
/**
 *  添加大头针
 */
- (void)addCustomAnnotation
{
    HYAnnotation *anno1 = [[HYAnnotation alloc] init];
    anno1.coordinate = CLLocationCoordinate2DMake(40.06, 116.39);
    anno1.title = @"帝都";
    anno1.subtitle = @"天朝帝都";
    
    HYAnnotation *anno2 = [[HYAnnotation alloc] init];
    anno2.coordinate = CLLocationCoordinate2DMake(23.23, 112.23);
    anno2.title = @"杭州";
    anno2.subtitle = @"阿里巴巴基地";
    
    [self.mapView addAnnotation:anno1];
    [self.mapView addAnnotation:anno2];
}

#pragma mark - mapView delegate

/**
 *  用户更新位置就会调用
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

/**
 *  每填加一个大头针就会调用这个方法 <类似于tableView的cellForRowAnIndexPath方法>
 *
 *  若返回nil<表示使用系统的大头针视图> 默认使用MKAnnotationView添加在mapView上是不显示的,但是的确已经添加上了,要想显示必须使用其子类 MKPinAnnotationView
 */
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 若是用户的位置则使用系统给的蓝色圆圈大头针,和其他的区分开来
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil ;
    
    // 先从缓存池中获取MKAnnotationView
    MKPinAnnotationView *annoView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annoIndentifier];
    
    // 如果MKAnnotationView为nil,则创建新的
    if (annoView == nil) {
        annoView = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:annoIndentifier];
        
        // 设置大头针视图的子标题和标题可以呼出
        annoView.canShowCallout = YES ;
        
        // 设置大头针颜色<枚举值,红色,绿色,紫色三种颜色>
        annoView.pinColor = MKPinAnnotationColorGreen ;
        
        // 是否以从天而降的动画方式显示
        annoView.animatesDrop = YES ;
    }
    
    // 把大头针模型赋值给大头针view
    annoView.annotation = annotation ;
    
    return annoView ;
}

@end
