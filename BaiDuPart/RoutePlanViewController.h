//
//  RoutePlanViewController.h
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/20.
//  Copyright © 2015年 young4ever. All rights reserved.
//

/**
 *  路线规划 : 可选择公交, 驾车 , 步行三种方式
 */

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface RoutePlanViewController : UIViewController<BMKMapViewDelegate, BMKRouteSearchDelegate>

/**
 *  路线切换按钮
 */
@property (nonatomic, strong) UISegmentedControl *segControl ;

/**
 *  起始城市输入框
 */
@property (nonatomic, strong) UITextField *startCityTF ;

/**
 *  起始地点输入框
 */
@property (nonatomic, strong) UITextField *startAddressTF ;

/**
 *  目的地城市输入框
 */
@property (nonatomic, strong) UITextField *endCityTF ;

/**
 *  目的地地址输入框
 */
@property (nonatomic, strong) UITextField *endAddressTF ;

/**
 *  百度mapView
 */
@property (nonatomic, strong) BMKMapView  *mapView ;

/**
 *  路线搜索器
 */
@property (nonatomic, strong) BMKRouteSearch *routeSearcher ;

@end
