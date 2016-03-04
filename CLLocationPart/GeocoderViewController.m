//
//  GeocoderViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/17.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "GeocoderViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Masonry.h"

@interface GeocoderViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *latitudeLabel ;
@property (nonatomic, strong) UILabel *longtitudeLabel ;
@property (nonatomic, strong) UITextField *addressTextField ;
@property (nonatomic, strong) UILabel *detailLabel ;

@end

@implementation GeocoderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"地理编码";
    
    UIBarButtonItem *codeItem = [[UIBarButtonItem alloc] initWithTitle:@"code" style:UIBarButtonItemStylePlain target:self action:@selector(codeItemAction:)];
    self.navigationItem.rightBarButtonItem = codeItem ;
    
    [self initSubviews];
}

#pragma mark
#pragma mark --- 地理编码
/**
 *  地理编码
 */
- (void)codeItemAction:(UIBarButtonItem *)item
{
    [_addressTextField resignFirstResponder];
    
    NSString *address = _addressTextField.text ;
    if (address.length == 0) return ;
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count == 0 || error) return ;
        
        /**  CLPlaceMark 相关属性
         name;                            // 地名
         thoroughfare;                    // 街道
         subThoroughfare;                 // 街道相关信息,例如门牌号等
         locality;                        // 城市
         subLocality;                     // 城市相关信息,例如标志性建筑等
         administrativeArea;              // 直辖市
         subAdministrativeArea;           // 其他行政区域信息
         postalCode;                      // 邮编
         ISOcountryCode;                  // 国家编码
         country;                         // 国家
         inlandWater;                     // 水源,湖泊
         ocean;                           // 海洋
         areasOfInterest                  // 关联的或利益相关的地标
         */
        int i = 0 ;
        for (CLPlacemark *pm in placemarks) {
            CLLocation *location = pm.location ;
            CLLocationCoordinate2D coordinate = location.coordinate ;
            
            if (i == 0) {
                self.latitudeLabel.text = [NSString stringWithFormat:@"纬度: 北纬%.2f度",coordinate.latitude];
                self.longtitudeLabel.text = [NSString stringWithFormat:@"经度: 东经%.2f度",coordinate.longitude];
                self.detailLabel.text = pm.name ;
            }
            
            i++ ;
        }
    }];
}

#pragma mark
#pragma mark --- 初始化子视图
/**
 *  初始化子视图
 */
- (void)initSubviews
{
    _addressTextField = [[UITextField alloc] init];
    _addressTextField.placeholder = @"请输入地址";
    _addressTextField.delegate = self;
    _addressTextField.borderStyle = UITextBorderStyleRoundedRect ;
    _addressTextField.backgroundColor = [UIColor clearColor];
    _addressTextField.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_addressTextField];
    [_addressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(80);
        make.height.equalTo(@30);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _latitudeLabel = [[UILabel alloc] init];
    _latitudeLabel.backgroundColor = [UIColor yellowColor];
    _latitudeLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_latitudeLabel];
    [_latitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addressTextField.mas_bottom).offset(20);
        make.height.equalTo(@30);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _longtitudeLabel = [[UILabel alloc] init];
    _longtitudeLabel.backgroundColor = [UIColor yellowColor];
    _longtitudeLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_longtitudeLabel];
    [_longtitudeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_latitudeLabel.mas_bottom).offset(20);
        make.height.equalTo(@30);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.backgroundColor = [UIColor yellowColor];
    _detailLabel.numberOfLines = 0 ;
    _detailLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_longtitudeLabel.mas_bottom).offset(20);
        make.height.equalTo(@100);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
}

#pragma mark
#pragma mark --- 收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
