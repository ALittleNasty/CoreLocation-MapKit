//
//  POISearchViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/19.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "POISearchViewController.h"
#import "Masonry.h"
#import "AppDelegate.h"

static NSString *annotationViewIdentifier = @"BMKAnnotationViewID";
@interface POISearchViewController ()

{
    int curPage ;
}

@property (nonatomic, strong) UIBarButtonItem *searchItem ;
@property (nonatomic, strong) UIBarButtonItem *nextPageItem ;

@end

@implementation POISearchViewController

#pragma mark
#pragma mark --- viewController lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self ;
    _poiSearcher.delegate = self ;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil ;
    _poiSearcher.delegate = nil ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"POI";
    self.view.backgroundColor = [UIColor blueColor];
    
    [self initSubviews];
    
    _poiSearcher  = [[BMKPoiSearch alloc] init];
    
    _cityTF.text = @"上海";
    _keyTF.text = @"餐厅";
}
#pragma mark
#pragma mark --- 初始化子视图
- (void)initSubviews
{
    _searchItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchItemAction:)];
    
    _nextPageItem = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStylePlain target:self action:@selector(nextPageItemAction:)];
    self.navigationItem.rightBarButtonItems = @[_nextPageItem, _searchItem] ;
    
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
    
    _keyTF = [[UITextField alloc] init];
    _keyTF.placeholder = @"请输入关键字(餐厅,影院...)";
    _keyTF.borderStyle = UITextBorderStyleRoundedRect ;
    _keyTF.backgroundColor = [UIColor clearColor];
    _keyTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_keyTF];
    [_keyTF mas_makeConstraints:^(MASConstraintMaker *make) {
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
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    _mapView.isSelectedAnnotationViewFront = YES ;
    [self.view addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cityTF.mas_bottom).offset(5);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
}
#pragma mark
#pragma mark --- 点击搜索 POI && 下一页搜索
/**
 *  点击搜索
 */
- (void)searchItemAction:(UIBarButtonItem *)item
{
    [_cityTF resignFirstResponder];
    [_keyTF resignFirstResponder];
    
    curPage = 0 ;
    NSString *cityStr = _cityTF.text ;
    NSString *keyWord = _keyTF.text ;
    
    if (cityStr.length == 0 || keyWord.length == 0) return ;
    
    [self searchPOIWithCity:cityStr keyWord:keyWord page:curPage];
}
/**
 *  下一页
 */
- (void)nextPageItemAction:(UIBarButtonItem *)item
{
    curPage ++ ;
    
    NSString *cityStr = _cityTF.text ;
    NSString *keyWord = _keyTF.text ;
    
    if (cityStr.length == 0 || keyWord.length == 0) return ;
    
    [self searchPOIWithCity:cityStr keyWord:keyWord page:curPage];
}
/**
 *  开始向百度服务器发起搜索请求
 *
 *  @param city    城市名称
 *  @param keyword 搜索的关键字
 *  @param page    第几页
 */
- (void)searchPOIWithCity:(NSString *)city keyWord:(NSString *)keyword page:(int)page
{
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = page;
    citySearchOption.city= city;
    citySearchOption.keyword = keyword;
    // 每一次请求多少条数据
    citySearchOption.pageCapacity = 10;
    
    BOOL flag = [_poiSearcher poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
}
#pragma mark
#pragma mark --- BMKMapView delegate method

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKPinAnnotationView *annoView = (BMKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
    if (annoView == nil) {
        annoView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
        // 设置大头针的颜色
        annoView.pinColor = BMKPinAnnotationColorGreen ;
        // 设置从天而降的动画效果
        annoView.animatesDrop = YES ;
    }
    // 设置位置
    annoView.centerOffset = CGPointMake(0, -(annoView.frame.size.height*0.5));
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annoView.canShowCallout = YES ;
    // 设置大头针model
    annoView.annotation = annotation ;
    // 设置是否可以拖拽
    annoView.draggable = NO ;
    
    return annoView ;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
#pragma mark
#pragma mark --- BMKPoiSearch delegate method

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    //先清除屏幕上所有的大头针view
    NSArray *annotations = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:annotations];
    
    //检索结果正常
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotationArray = [NSMutableArray array];
        
        for (int i = 0 ; i < poiResult.poiInfoList.count; i++) {
            BMKPoiInfo *info = [poiResult.poiInfoList objectAtIndex:i];
            BMKPointAnnotation *anno = [[BMKPointAnnotation alloc] init];
            anno.coordinate = info.pt ;
            anno.title = info.name ;
            anno.subtitle = info.address ;
            [annotationArray addObject:anno];
        }
        
        [_mapView addAnnotations:annotationArray];
        [_mapView showAnnotations:annotationArray animated:YES];
    }
}

- (void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
    
}

#pragma mark
#pragma mark --- 收起键盘

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_cityTF resignFirstResponder];
    [_keyTF resignFirstResponder];
}

#pragma mark
#pragma mark --- 销毁对象,释放资源

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil ;
    }
    if (_poiSearcher) {
        _poiSearcher = nil ;
    }
}
@end
