//
//  BusLineSearchViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "BusLineSearchViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "AppDelegate.h"
#import "Masonry.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface BusLineAnnotation : BMKPointAnnotation
{
    int _type; // -> 0:起点 1：终点 2：公交 3：地铁 4:驾乘
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation BusLineAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface BusLineSearchViewController ()

@property (nonatomic, strong) UIBarButtonItem *upSearchItem ;
@property (nonatomic, strong) UIBarButtonItem *downSearchItem ;

@end

@implementation BusLineSearchViewController

#pragma mark
#pragma mark --- viewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"公交查询";
    
    [self initSubviews];
    
    _busLineSearcher = [[BMKBusLineSearch alloc] init];
    _busLineSearcher.delegate = self ;
    _poiSearcher = [[BMKPoiSearch alloc] init];
    _poiSearcher.delegate = self ;
    
    _currentIndex = -1 ;
    _busPOIArray = [[NSMutableArray alloc] init];
    _cityTF.text = @"上海";
    _busLineTF.text = @"713";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self ;
    _poiSearcher.delegate = self ;
    _busLineSearcher.delegate = self ;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _poiSearcher.delegate = nil ;
    _busLineSearcher.delegate = nil ;
}

#pragma mark
#pragma mark --- 初始化子视图

- (void)initSubviews
{
    _upSearchItem = [[UIBarButtonItem alloc] initWithTitle:@"上行" style:UIBarButtonItemStylePlain target:self action:@selector(busLineUpSearch)];
    
    _downSearchItem = [[UIBarButtonItem alloc] initWithTitle:@"下行" style:UIBarButtonItemStylePlain target:self action:@selector(busLineDownSearch)];
    self.navigationItem.rightBarButtonItems = @[_upSearchItem, _downSearchItem] ;
    
    _cityTF = [[UITextField alloc] init];
    _cityTF.placeholder = @"请输入城市";
    _cityTF.borderStyle = UITextBorderStyleRoundedRect ;
    _cityTF.backgroundColor = [UIColor clearColor];
    _cityTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_cityTF];
    [_cityTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(70);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_centerX).offset(-5);
    }];
    
    _busLineTF = [[UITextField alloc] init];
    _busLineTF.placeholder = @"请输入公交线路名称(例如:713)";
    _busLineTF.borderStyle = UITextBorderStyleRoundedRect ;
    _busLineTF.backgroundColor = [UIColor clearColor];
    _busLineTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_busLineTF];
    [_busLineTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(70);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_centerX).offset(5);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    double latitude = ((AppDelegate*)[UIApplication sharedApplication].delegate).latitude ;
    double longitude = ((AppDelegate*)[UIApplication sharedApplication].delegate).longitude ;
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.mapType = BMKMapTypeStandard ;
    _mapView.zoomLevel = 13.f ;
    _mapView.delegate = self ;
    if (latitude != 0.0 && longitude != 0.0) {
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
        [_mapView setCenterCoordinate:center animated:YES];
    }
    _mapView.isSelectedAnnotationViewFront = YES ;
    [self.view addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cityTF.mas_bottom).offset(5);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
}

#pragma mark -
#pragma mark --- BMKMapView Delegate Method
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BusLineAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(BusLineAnnotation*)annotation];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        polylineView.isFocus = YES ;
        
        [polylineView setNeedsDisplayInMapRect:map.visibleMapRect];
        
        return polylineView;
    }
    return nil;
}


#pragma mark -
#pragma mark  BMKSearch Delegate Method

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
//        BMKPoiInfo *info = nil ;
        BOOL findBusLine = NO ;
        for (BMKPoiInfo * info in poiResult.poiInfoList) {
            if (info.epoitype == 2 || info.epoitype == 4) { // 2: 公交线路 4:地铁线路
                findBusLine = YES ;
                [_busPOIArray addObject:info];
            }
        }
        
        if (findBusLine){
            _currentIndex = 0 ;
            NSString *uidStr = ((BMKPoiInfo*)[_busPOIArray objectAtIndex:_currentIndex]).uid ;
            BMKBusLineSearchOption *option = [[BMKBusLineSearchOption alloc] init];
            option.city = _cityTF.text ;
            option.busLineUid = uidStr ;
            BOOL flag = [_busLineSearcher busLineSearch:option];
            if (flag) {
                NSLog(@"busline检索发送成功");
            }else{
                NSLog(@"busline检索发送失败");
            }
        }
    }
}

- (void)onGetBusDetailResult:(BMKBusLineSearch *)searcher result:(BMKBusLineResult *)busLineResult errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        
        BusLineAnnotation* item = [[BusLineAnnotation alloc]init];
        
        //站点信息
        NSInteger size = 0;
        size = busLineResult.busStations.count;
        for (NSInteger j = 0; j < size; j++) {
            BMKBusStation* station = [busLineResult.busStations objectAtIndex:j];
            item = [[BusLineAnnotation alloc]init];
            item.coordinate = station.location;
            item.title = station.title;
            
            if (j == 0) {
                item.type = 0 ;
            }else if (j == size-1){
                item.type = 1 ;
            }else{
                item.type = 2;
            }
            [_mapView addAnnotation:item];
        }
        
        
        //路段信息
        NSInteger index = 0;
        //累加index为下面声明数组temppoints时用
        for (NSInteger j = 0; j < busLineResult.busSteps.count; j++) {
            BMKBusStep* step = [busLineResult.busSteps objectAtIndex:j];
            index += step.pointsCount;
        }
        //直角坐标划线
        BMKMapPoint * temppoints = new BMKMapPoint[index];
        NSInteger k=0;
        for (NSInteger i = 0; i < busLineResult.busSteps.count; i++) {
            BMKBusStep* step = [busLineResult.busSteps objectAtIndex:i];
            for (NSInteger j = 0; j < step.pointsCount; j++) {
                BMKMapPoint pointarray;
                pointarray.x = step.points[j].x;
                pointarray.y = step.points[j].y;
                temppoints[k] = pointarray;
                k++;
            }
        }
        
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:index];
        [_mapView addOverlay:polyLine];
        delete temppoints;
        
        BMKBusStation* start = [busLineResult.busStations objectAtIndex:0];
        [_mapView setCenterCoordinate:start.location animated:YES];
        
    }
}

#pragma mark
#pragma mark --- 根据不同的地点设置不同的大头针view  0:起点 1：终点 2：公交 3：地铁 4:驾乘

- (BMKAnnotationView *)getRouteAnnotationView:(BMKMapView *)mapView viewForAnnotation:(BusLineAnnotation *)routeAnnotation
{
    BMKAnnotationView *view = nil ;
    
    switch (routeAnnotation.type) {
        case 0: // 0:起点
        {
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = YES ;
            }
            view.annotation = routeAnnotation ;
        }
            break;
        case 1: // 1：终点
        {
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/icon_nav_end.png"]];
                view.canShowCallout = YES ;
            }
            view.annotation = routeAnnotation ;
        }
            break;
        case 2: // 2：公交
        {
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/icon_nav_bus.png"]];
                view.canShowCallout = YES;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3: // 3：地铁
        {
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4: // 4:驾乘
        {
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = YES ;
            }else{
                [view setNeedsDisplay];
            }
            UIImage *img = [UIImage imageWithContentsOfFile:[self getMyBundlePath:@"images/icon_direction.png"]];
            view.image = [self imageRotatedByDegrees:routeAnnotation.degree WithOriginalImage:img];
        }
            break;
        default:
            break;
    }
    
    return view ;
}

#pragma mark
#pragma mark --- 公交线路上行,下行查询 <公共方法>
/**
 *  上行
 */
- (void)busLineUpSearch
{
    [_busPOIArray removeAllObjects];
    
    BMKCitySearchOption *option = [[BMKCitySearchOption alloc] init];
    option.pageIndex = 0 ;
    option.pageCapacity = 10 ;
    
    NSString *cityStr = _cityTF.text ;
    NSString *lineStr = _busLineTF.text ;
    if (cityStr.length == 0 || lineStr.length == 0) return ;
    
    option.city = cityStr ;
    option.keyword = lineStr ;
    
    BOOL ret = [_poiSearcher poiSearchInCity:option] ;
    if (ret) {
        NSLog(@"公交查询检索发送成功");
    }else{
        NSLog(@"公交查询检索发送失败");
    }
}
/**
 *  下行
 */
- (void)busLineDownSearch
{
    if (_busPOIArray.count > 0){ //已经查询到数据
        
        if (++_currentIndex >= _busPOIArray.count){
            _currentIndex -= _busPOIArray.count ;
        }
        NSString *uidStr = ((BMKPoiInfo*)[_busPOIArray objectAtIndex:_currentIndex]).uid ;
        BMKBusLineSearchOption *busLineSearchOption = [[BMKBusLineSearchOption alloc] init];
        NSString *cityStr = _cityTF.text ;
        NSString *lineStr = _busLineTF.text ;
        if (cityStr.length == 0 || lineStr.length == 0) return ;
        busLineSearchOption.city = cityStr ;
        busLineSearchOption.busLineUid = uidStr ;
        BOOL ret = [_busLineSearcher busLineSearch:busLineSearchOption];
        if (ret) {
            NSLog(@"公交查询检索发送成功");
        }else{
            NSLog(@"公交查询检索发送失败");
        }
    
    }else{                       //未查询到数据
        BMKCitySearchOption *option = [[BMKCitySearchOption alloc] init];
        option.pageIndex = 0 ;
        option.pageCapacity = 10 ;
        
        NSString *cityStr = _cityTF.text ;
        NSString *lineStr = _busLineTF.text ;
        if (cityStr.length == 0 || lineStr.length == 0) return ;
        
        option.city = cityStr ;
        option.keyword = lineStr ;
        
        BOOL ret = [_poiSearcher poiSearchInCity:option] ;
        if (ret) {
            NSLog(@"公交查询检索发送成功");
        }else{
            NSLog(@"公交查询检索发送失败");
        }
    }
}

#pragma mark
#pragma mark --- 从百度的资源包bundle中取图片
- (NSString *)getMyBundlePath:(NSString *)filename
{
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * name = [[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return name;
    }
    return nil ;
}

#pragma mark
#pragma mark --- 给一个角度旋转图片
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees WithOriginalImage:(UIImage *)image
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), image.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark
#pragma mark --- 收起键盘

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_cityTF resignFirstResponder];
    [_busLineTF resignFirstResponder];
}

#pragma mark
#pragma mark --- 销毁对象, 释放资源

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil ;
    }
    if (_poiSearcher) {
        _poiSearcher = nil ;
    }
    if (_busLineSearcher) {
        _busLineSearcher = nil ;
    }
    if (_busPOIArray) {
        _busPOIArray = nil ;
    }
}
@end
