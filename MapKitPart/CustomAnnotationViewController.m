//
//  CustomAnnotationViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "CustomAnnotationViewController.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"
#import "HYAnnotation.h"
#import "HYAnnotationView.h"


static NSString *annoViewIdentifier = @"customAnnotationViewID";
@interface CustomAnnotationViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView ;

@property (nonatomic, strong) UIButton  *annoButton ;

@end

@implementation CustomAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义大头针";
    
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
    anno1.icon = @"category_1";
    
    HYAnnotation *anno2 = [[HYAnnotation alloc] init];
    anno2.coordinate = CLLocationCoordinate2DMake(33.23, 112.23);
    anno2.title = @"杭州";
    anno2.subtitle = @"阿里巴巴基地";
    anno2.icon = @"category_3";
    
    [self.mapView addAnnotation:anno1];
    [self.mapView addAnnotation:anno2];
}

#pragma mark
#pragma mark --- mapView delegate

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
//- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    // 若是用户的位置则使用系统给的蓝色圆圈大头针,和其他的区分开来
//    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil ;
//    
//    HYAnnotationView *annoView = (HYAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annoViewIdentifier];
//    
//    if (annoView == nil) {
//        annoView = [[HYAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:annoViewIdentifier];
//        annoView.canShowCallout = YES ;
//    }
//    
//    HYAnnotation *anno = (HYAnnotation *)annotation ;
//    annoView.image = [UIImage imageNamed:anno.icon];
//    annoView.annotation = anno ; //这行代码可以不写 , 系统会自动调用
//    return annoView ;
//}
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 若是用户的位置则使用系统给的蓝色圆圈大头针,和其他的区分开来
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil ;
    
    HYAnnotationView *annoView = [HYAnnotationView annotationViewWithMapView:mapView] ;
    
    return annoView ;
}

/**
 *  所有的大头针视图都已经添加上去的时候但还没有显示调用<可以自定义动画>
 *
 *  @param views   存放所有的大头针的View的数组
 */
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    for (MKAnnotationView *annoView in views) {
        if ([annoView.annotation isKindOfClass:[MKUserLocation class]]) return ;
        
        CGRect endFrame = annoView.frame ;
        
        annoView.frame = CGRectMake(0, endFrame.origin.y, endFrame.size.width, endFrame.size.height) ;
        
        [UIView animateWithDuration:0.5 animations:^{
            annoView.frame = endFrame ;
        }];
    }
}
@end
