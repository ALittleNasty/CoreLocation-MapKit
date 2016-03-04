//
//  BusLineSearchViewController.h
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

/**
 *  公交线路搜索
 */

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>


@interface BusLineSearchViewController : UIViewController<BMKPoiSearchDelegate,
                                                          BMKBusLineSearchDelegate,
                                                          BMKMapViewDelegate>
/**
 *  城市输入框
 */
@property (nonatomic, strong) UITextField *cityTF ;

/**
 *  公交线路输入框
 */
@property (nonatomic, strong) UITextField *busLineTF ;

/**
 *  存放公交站点的数组
 */
@property (nonatomic, strong) NSMutableArray *busPOIArray ;

/**
 *  当前索引
 */
@property (nonatomic, assign) int            currentIndex ;

/**
 *  百度mapView
 */
@property (nonatomic, strong) BMKMapView *mapView ;

/**
 *  百度poi搜索类
 */
@property (nonatomic, strong) BMKPoiSearch *poiSearcher ;

/**
 *  百度公交线路搜索类
 */
@property (nonatomic, strong) BMKBusLineSearch *busLineSearcher ;

/**
 *  百度公交站点的大头针模型
 */
@property (nonatomic, strong) BMKPointAnnotation *annotation ;


#pragma mark
#pragma mark --- public methods

/**
 *  公交路线上行查询
 */
- (void)busLineUpSearch ;

/**
 *  公交路线下行查询
 */
- (void)busLineDownSearch ;

@end
