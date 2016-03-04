//
//  ViewController.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/17.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "ViewController.h"
#import "CLLocationViewController.h"
#import "GeocoderViewController.h"
#import "ReverseGeocoderViewController.h"
#import "MapViewController.h"
#import "AnnotationViewController.h"
#import "CustomAnnotationViewController.h"
#import "NavigateViewController.h"
#import "MapLineViewController.h"
#import "BaiDuViewController.h"
#import "BLocationViewController.h"
#import "POISearchViewController.h"
#import "BusLineSearchViewController.h"
#import "RoutePlanViewController.h"

static NSString *cellReuseID = @"homeCellReuseID";
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *classArray ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor yellowColor];
    
    
    _classArray = @[NSStringFromClass([CLLocationViewController class]),
                    NSStringFromClass([GeocoderViewController class]),
                    NSStringFromClass([ReverseGeocoderViewController class]),
                    NSStringFromClass([MapViewController class]),
                    NSStringFromClass([AnnotationViewController class]),
                    NSStringFromClass([CustomAnnotationViewController class]),
                    NSStringFromClass([NavigateViewController class]),
                    NSStringFromClass([MapLineViewController class]),
                    NSStringFromClass([BaiDuViewController class]),
                    NSStringFromClass([BLocationViewController class]),
                    NSStringFromClass([POISearchViewController class]),
                    NSStringFromClass([BusLineSearchViewController class]),
                    NSStringFromClass([RoutePlanViewController class])];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseID];
}

#pragma mark
#pragma mark --- tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _classArray.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.f ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID forIndexPath:indexPath] ;
    cell.textLabel.text = _classArray[indexPath.row] ;
    cell.textLabel.textColor = [UIColor orangeColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textAlignment = NSTextAlignmentCenter ;
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    return cell ;
}

#pragma mark
#pragma mark --- tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = _classArray[indexPath.row] ;
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
