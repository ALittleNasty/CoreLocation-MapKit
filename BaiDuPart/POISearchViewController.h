//
//  POISearchViewController.h
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

/**
 *  POI 搜索
 */

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface POISearchViewController : UIViewController<BMKMapViewDelegate,BMKPoiSearchDelegate>

/**
 *  城市输入框
 */
@property (nonatomic, strong) UITextField  *cityTF ;

/**
 *  关键字输入框
 */
@property (nonatomic, strong) UITextField  *keyTF ;

/**
 *  百度 mapView
 */
@property (nonatomic, strong) BMKMapView   *mapView ;

/**
 *  百度poi 搜索器
 */
@property (nonatomic, strong) BMKPoiSearch *poiSearcher;


@end
