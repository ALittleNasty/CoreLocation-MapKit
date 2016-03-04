//
//  ReverseGeocoderViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "ReverseGeocoderViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Masonry.h"

@interface ReverseGeocoderViewController ()

@property (nonatomic, strong) UITextField *latitudeTF ;
@property (nonatomic, strong) UITextField *longitudeTF ;
@property (nonatomic, strong) UILabel     *addressLabel ;

@end

@implementation ReverseGeocoderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地理编码";
    
    UIBarButtonItem *reverseCodeItem = [[UIBarButtonItem alloc] initWithTitle:@"reverseCode" style:UIBarButtonItemStylePlain target:self action:@selector(reverseCodeItemAction:)];
    self.navigationItem.rightBarButtonItem = reverseCodeItem ;
    
    [self initSubviews];
    
}

#pragma mark
#pragma mark --- 反地理编码
/**
 *  地理反编码
 */
- (void)reverseCodeItemAction:(UIBarButtonItem *)item
{
    [self.latitudeTF resignFirstResponder];
    [self.longitudeTF resignFirstResponder];
    
    NSString *latitude = _latitudeTF.text ;
    NSString *longitude = _longitudeTF.text ;
    if (latitude.length == 0 || longitude.length == 0) {
        return ;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) {
            return ;
        }
        
        CLPlacemark *pm = [placemarks firstObject];
        if (pm.locality) {
            self.addressLabel.text = pm.locality ;
        }else{
            self.addressLabel.text = pm.administrativeArea ;
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
    _latitudeTF = [[UITextField alloc] init];
    _latitudeTF.placeholder = @"请输入纬度";
    _latitudeTF.borderStyle = UITextBorderStyleRoundedRect ;
    _latitudeTF.backgroundColor = [UIColor clearColor];
    _latitudeTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_latitudeTF];
    [_latitudeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(80);
        make.height.equalTo(@30);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _longitudeTF = [[UITextField alloc] init];
    _longitudeTF.placeholder = @"请输入经度";
    _longitudeTF.borderStyle = UITextBorderStyleRoundedRect ;
    _longitudeTF.backgroundColor = [UIColor clearColor];
    _longitudeTF.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_longitudeTF];
    [_longitudeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_latitudeTF.mas_bottom).offset(20);
        make.height.equalTo(@30);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];
    
    _addressLabel = [[UILabel alloc] init];
    _addressLabel.numberOfLines = 0 ;
    _addressLabel.backgroundColor = [UIColor yellowColor];
    _addressLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:_addressLabel];
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_longitudeTF.mas_bottom).offset(20);
        make.height.equalTo(@80);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
    }];

}

#pragma mark
#pragma mark --- 收起键盘

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.latitudeTF resignFirstResponder];
    [self.longitudeTF resignFirstResponder];
}

@end
