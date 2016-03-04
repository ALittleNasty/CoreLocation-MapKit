//
//  HYAnnotation.h
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HYAnnotation : NSObject<MKAnnotation>

/**
 *  坐标<经纬度>
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  副标题
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 *  icon
 */
@property (nonatomic, copy) NSString *icon ;

@end
