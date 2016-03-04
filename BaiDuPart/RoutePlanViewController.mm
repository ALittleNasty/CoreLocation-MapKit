//
//  RoutePlanViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/20.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "RoutePlanViewController.h"
#import "AppDelegate.h"
#import "Masonry.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;

@end

@interface RoutePlanViewController ()

@end

@implementation RoutePlanViewController

#pragma mark 
#pragma mark --- viewController lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self ;
    _routeSearcher.delegate = self ;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil ;
    _routeSearcher.delegate = nil ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _routeSearcher = [[BMKRouteSearch alloc] init];
    _routeSearcher.delegate = self;
    
    [self setupNavigationBarItem];
    [self initSubviews];
    [self searchBusRoute];
}

#pragma mark
#pragma mark --- init subViews

- (void)setupNavigationBarItem
{
    CGFloat fullWidth = [UIScreen mainScreen].bounds.size.width ;
    _segControl = [[UISegmentedControl alloc] init];
    _segControl.tag = 100 ;
    _segControl.frame = CGRectMake((fullWidth-200)/2, 12.f, 200.f, 30.f) ;
    _segControl.backgroundColor = [UIColor whiteColor] ;
    
    [_segControl setTintColor:[UIColor blueColor]];
    [_segControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blueColor]} forState:UIControlStateNormal];
    [_segControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    _segControl.layer.borderWidth = 1.f ;
    _segControl.layer.borderColor = [UIColor blueColor].CGColor ;
    _segControl.layer.cornerRadius = 10/2.0 ;
    _segControl.layer.masksToBounds = YES;
    [_segControl insertSegmentWithTitle:@"公交" atIndex:0 animated:NO];
    [_segControl insertSegmentWithTitle:@"驾乘" atIndex:1 animated:NO];
    [_segControl insertSegmentWithTitle:@"步行" atIndex:2 animated:NO];
    _segControl.selectedSegmentIndex = 0 ;
    [_segControl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged] ;
    self.navigationItem.titleView = _segControl ;
}

- (void)segmentChange:(UISegmentedControl *)seg
{
    [self backKeyboard];
    if (seg.selectedSegmentIndex == 0) {
        // 公交
        [self searchBusRoute];
    }else if (seg.selectedSegmentIndex == 1){
        // 驾乘
        [self searchDriveRoute];
    }else if (seg.selectedSegmentIndex == 2){
        // 步行
        [self searchWalkRoute];
    }
}

- (void)initSubviews
{
    _startCityTF = [[UITextField alloc] init];
    _startCityTF.placeholder = @"请输入起点城市";
    _startCityTF.borderStyle = UITextBorderStyleRoundedRect ;
    _startCityTF.backgroundColor = [UIColor clearColor];
    _startCityTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_startCityTF];
    [_startCityTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(70);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_centerX).offset(-5);
    }];
    
    _endCityTF = [[UITextField alloc] init];
    _endCityTF.placeholder = @"请输入终点城市";
    _endCityTF.borderStyle = UITextBorderStyleRoundedRect ;
    _endCityTF.backgroundColor = [UIColor clearColor];
    _endCityTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_endCityTF];
    [_endCityTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(70);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_centerX).offset(5);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    _startAddressTF = [[UITextField alloc] init];
    _startAddressTF.placeholder = @"请输入起点地址";
    _startAddressTF.borderStyle = UITextBorderStyleRoundedRect ;
    _startAddressTF.backgroundColor = [UIColor clearColor];
    _startAddressTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_startAddressTF];
    [_startAddressTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_startCityTF.mas_bottom).offset(5);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
    }];
    
    _endAddressTF = [[UITextField alloc] init];
    _endAddressTF.placeholder = @"请输入终点地址";
    _endAddressTF.borderStyle = UITextBorderStyleRoundedRect ;
    _endAddressTF.backgroundColor = [UIColor clearColor];
    _endAddressTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_endAddressTF];
    [_endAddressTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_startAddressTF.mas_bottom).offset(5);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_left).offset(10);
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
        make.top.equalTo(_endAddressTF.mas_bottom).offset(5);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    
    _startCityTF.text = @"上海";
    _startAddressTF.text = @"五角场";
    _endCityTF.text = @"上海";
    _endAddressTF.text = @"外滩";
}


#pragma mark -
#pragma mark --- BMKMapView Delegate Method
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
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
/**
 *  公交搜索结果
 *
 *  @param searcher 路线搜索器类
 *  @param result   公交路线搜索结果
 *  @param error    搜索结果枚举值
 */
- (void)onGetTransitRouteResult:(BMKRouteSearch *)searcher result:(BMKTransitRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    // 先清除以前的大头针模型和折线图
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    // 处理正确的搜索结果
    if (error == BMK_SEARCH_NO_ERROR) {
        
        // 返回结果result中会有多条路线 , 我们选择第一条演示
        BMKTransitRouteLine *plan = (BMKTransitRouteLine *)[result.routes objectAtIndex:0];
        
        //计算路线方案中的路段数目
        NSInteger size = plan.steps.count ;
        int planPointCount = 0 ;
        for (int i = 0 ; i < size; i++) {
            BMKTransitStep *transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                RouteAnnotation *item = [[RouteAnnotation alloc] init];
                item.coordinate = plan.starting.location ;
                item.title = @"起点";
                item.type = 0 ;
                [_mapView addAnnotation:item];
            } else if (i == size - 1){
                RouteAnnotation *item = [[RouteAnnotation alloc] init];
                item.coordinate = plan.terminal.location ;
                item.title = @"终点";
                item.type = 1 ;
                [_mapView addAnnotation:item];
            }
            
            RouteAnnotation *item = [[RouteAnnotation alloc] init];
            item.coordinate = transitStep.entrace.location ;
            item.title = transitStep.instruction ;
            
            if (transitStep.stepType == BMK_SUBWAY) {
                item.type = 3 ;
            } else {
                item.type = 2 ;
            }
            
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCount += transitStep.pointsCount ;
        }
        
        //轨迹点
        BMKMapPoint *temppoints = new BMKMapPoint[planPointCount] ;
        int i = 0 ;
        for (int j = 0 ; j < size; j++) {
            BMKTransitStep *step = [plan.steps objectAtIndex:j];
            int k = 0 ;
            for (k = 0; k < step.pointsCount ; k++) {
                temppoints[i].x = step.points[k].x ;
                temppoints[i].y = step.points[k].y ;
                i++ ;
            }
        }
        
        //通过points构建BMKPolyline
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:temppoints count:planPointCount] ;
        [_mapView addOverlay:polyline];
        
        delete []temppoints;
        [self mapViewFitPolyLine:polyline];
    }
}

/**
 *  驾车搜索结果
 *
 *  @param searcher 路线搜索器类
 *  @param result   驾车路线搜索结果
 *  @param error    搜索结果枚举值
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    // 先清除以前的大头针模型和折线图
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    // 处理正确的搜索结果
    if (error == BMK_SEARCH_NO_ERROR) {
        
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}

/**
 *  步行搜索结果
 *
 *  @param searcher 路线搜索器类
 *  @param result   步行搜索路线结果
 *  @param error    搜索结果枚举值
 */
- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher result:(BMKWalkingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    // 先清除以前的大头针模型和折线图
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    // 处理正确的搜索结果
    if (error == BMK_SEARCH_NO_ERROR) {
     
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}


#pragma mark
#pragma mark --- 搜索三种路线 <公交 , 驾车 , 步行>
/**
 *  公交
 */
- (void)searchBusRoute
{
    NSString *fromCity = _startCityTF.text;
    NSString *from = _startAddressTF.text ;
    NSString *toCity = _endCityTF.text ;
    NSString *to = _endAddressTF.text ;
    if (from.length == 0 || to.length == 0 || fromCity.length == 0 || toCity.length == 0) return ;
    
    BMKPlanNode *fromNode = [[BMKPlanNode alloc] init];
    fromNode.name = from ;
    fromNode.cityName = fromCity ;
    
    BMKPlanNode *toNode = [[BMKPlanNode alloc] init];
    toNode.name = to ;
    toNode.cityName = toCity ;
    
    BMKTransitRoutePlanOption *planOption = [[BMKTransitRoutePlanOption alloc] init];
    /*
     BMK_TRANSIT_TIME_FIRST = 3,		//较快捷(公交)
     BMK_TRANSIT_TRANSFER_FIRST = 4,	//少换乘(公交)
     BMK_TRANSIT_WALK_FIRST = 5,		//少步行(公交)
     BMK_TRANSIT_NO_SUBWAY = 6,		    //不坐地铁
     */
    planOption.transitPolicy = BMK_TRANSIT_TRANSFER_FIRST ;
    planOption.city = fromCity ;
    planOption.from = fromNode ;
    planOption.to = toNode ;
    
    BOOL flag = [_routeSearcher transitSearch:planOption];
    if (flag) {
        NSLog(@"bus search request success");
    }else{
        NSLog(@"bus search request failed");
    }
}
/**
 *  驾车
 */
- (void)searchDriveRoute
{
    NSString *fromCity = _startCityTF.text;
    NSString *from = _startAddressTF.text ;
    NSString *toCity = _endCityTF.text ;
    NSString *to = _endAddressTF.text ;
    if (from.length == 0 || to.length == 0 || fromCity.length == 0 || toCity.length == 0) return ;
    
    BMKPlanNode *fromNode = [[BMKPlanNode alloc] init];
    fromNode.name = from ;
    fromNode.cityName = fromCity ;
    
    BMKPlanNode *toNode = [[BMKPlanNode alloc] init];
    toNode.name = to ;
    toNode.cityName = toCity ;
    
    BMKDrivingRoutePlanOption *planOption = [[BMKDrivingRoutePlanOption alloc] init];
    /*
     BMK_DRIVING_BLK_FIRST = -1, //躲避拥堵(自驾)
     BMK_DRIVING_TIME_FIRST = 0,	//最短时间(自驾)
     BMK_DRIVING_DIS_FIRST = 1,	//最短路程(自驾)
     BMK_DRIVING_FEE_FIRST,		//少走高速(自驾)
     */
    planOption.drivingPolicy = BMK_DRIVING_TIME_FIRST ;
    planOption.from = fromNode ;
    planOption.to = toNode ;
    
    BOOL flag = [_routeSearcher drivingSearch:planOption];
    if (flag) {
        NSLog(@"drive search request success");
    }else{
        NSLog(@"drive search request failed");
    }
}
/**
 *  步行
 */
- (void)searchWalkRoute
{
    NSString *fromCity = _startCityTF.text;
    NSString *from = _startAddressTF.text ;
    NSString *toCity = _endCityTF.text ;
    NSString *to = _endAddressTF.text ;
    if (from.length == 0 || to.length == 0 || fromCity.length == 0 || toCity.length == 0) return ;
    
    BMKPlanNode *fromNode = [[BMKPlanNode alloc] init];
    fromNode.name = from ;
    fromNode.cityName = fromCity ;
    
    BMKPlanNode *toNode = [[BMKPlanNode alloc] init];
    toNode.name = to ;
    toNode.cityName = toCity ;
    
    BMKWalkingRoutePlanOption *planOption = [[BMKWalkingRoutePlanOption alloc] init];
    planOption.from = fromNode ;
    planOption.to = toNode ;
    BOOL flag = [_routeSearcher walkingSearch:planOption];
    if (flag) {
        NSLog(@"walk search request success");
    }else{
        NSLog(@"walk search request failed");
    }
}

#pragma mark
#pragma mark --- 根据不同的地点设置不同的大头针view  0:起点 1：终点 2：公交 3：地铁 4:驾乘

- (BMKAnnotationView *)getRouteAnnotationView:(BMKMapView *)mapView viewForAnnotation:(RouteAnnotation *)routeAnnotation
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
#pragma mark --- 根据polyline设置地图范围

- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
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
    [self backKeyboard];
}

- (void)backKeyboard
{
    [_startAddressTF resignFirstResponder];
    [_startCityTF resignFirstResponder];
    [_endAddressTF resignFirstResponder];
    [_endCityTF resignFirstResponder];
}

#pragma mark
#pragma mark --- 销毁对象 , 释放资源
- (void)dealloc
{
    if (_mapView) {
        _mapView = nil ;
    }
    if (_routeSearcher ) {
        _routeSearcher = nil ;
    }
}

@end
