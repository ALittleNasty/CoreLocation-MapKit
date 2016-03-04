//
//  NavigateViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "NavigateViewController.h"
#import "Masonry.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NavigateViewController ()

@property (nonatomic, strong) UITextField *destinationTF ;

@property (nonatomic, strong) UIButton    *navigateButton ;

@end

@implementation NavigateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _destinationTF = [[UITextField alloc] init];
    _destinationTF.placeholder = @"请输入您的目的地";
    _destinationTF.borderStyle = UITextBorderStyleRoundedRect ;
    _destinationTF.backgroundColor = [UIColor clearColor];
    _destinationTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_destinationTF];
    [_destinationTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(80);
        make.height.equalTo(@40);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _navigateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _navigateButton.backgroundColor = [UIColor orangeColor];
    _navigateButton.layer.masksToBounds = YES ;
    _navigateButton.layer.cornerRadius = 10.f ;
    [_navigateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_navigateButton setTitle:@"导航" forState:UIControlStateNormal];
    [_navigateButton addTarget:self action:@selector(navigateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_navigateButton];
    [_navigateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.destinationTF.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(200.f, 60.f));
    }];
}

#pragma mark
#pragma mark --- 开始导航
/**
 *  导航按钮的事件方法
 */
- (void)navigateButtonAction
{
    NSString *destination = self.destinationTF.text ;
    if (destination.length == 0) return ;
    
    
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:destination completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) return ;
        
        CLPlacemark *pm = [placemarks firstObject];
        MKPlacemark *m_PM = [[MKPlacemark alloc] initWithPlacemark:pm];
        
        
        MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:m_PM];
        MKMapItem *startItem = [MKMapItem mapItemForCurrentLocation] ;
        
        [self startNavigateWithStartItem:startItem andEndItem:endItem];
    }];
}

- (void)startNavigateWithStartItem:(MKMapItem *)startItem andEndItem:(MKMapItem *)endItem
{
    // 1.拿到起始点item和终点item的数组
    NSArray *items = @[startItem,endItem];
    
    // 2.获取参数字典
    /**
     // 导航模式<驾车,步行,航行>
     MK_EXTERN NSString * const MKLaunchOptionsDirectionsModeKey     NS_AVAILABLE(10_9, 6_0); // Key to a directions mode
     // 地图类型<标准,卫星,混合地图>
     MK_EXTERN NSString * const MKLaunchOptionsMapTypeKey            NS_AVAILABLE(10_9, 6_0) __WATCHOS_PROHIBITED; // Key to an NSNumber corresponding to a MKMapType
     // 是否显示交通状况<布尔类型包装成NSNumber>
     MK_EXTERN NSString * const MKLaunchOptionsShowsTrafficKey       NS_AVAILABLE(10_9, 6_0) __WATCHOS_PROHIBITED; // Key to a boolean NSNumber
     
     // Directions modes
     MK_EXTERN NSString * const MKLaunchOptionsDirectionsModeDriving NS_AVAILABLE(10_9, 6_0);
     MK_EXTERN NSString * const MKLaunchOptionsDirectionsModeWalking NS_AVAILABLE(10_9, 6_0);
     MK_EXTERN NSString * const MKLaunchOptionsDirectionsModeTransit NS_AVAILABLE(10_11, 9_0);
     */
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                              MKLaunchOptionsMapTypeKey       :@(MKMapTypeStandard),
                              MKLaunchOptionsShowsTrafficKey  :@YES};
    
    // 3.开始导航
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark
#pragma mark --- 收起键盘

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.destinationTF resignFirstResponder];
}

@end
