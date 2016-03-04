//
//  HYAnnotationView.m
//  CLLocationAndMapKit
//
//  Created by 胡阳 on 15/11/18.
//  Copyright © 2015年 young4ever. All rights reserved.
//

#import "HYAnnotationView.h"
#import "HYAnnotation.h"

static NSString *HYAnnotationViewReuseID = @"HYAnnotationViewID";
@implementation HYAnnotationView

- (void)setAnnotation:(HYAnnotation *)annotation
{
    [super setAnnotation:annotation];
    
    if (annotation.icon != nil && annotation.icon.length > 0) {
        self.image = [UIImage imageNamed:annotation.icon] ;
    }    
}

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView
{
    HYAnnotationView *annoView = (HYAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:HYAnnotationViewReuseID];
    
    if (annoView == nil) {
        annoView = [[HYAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:HYAnnotationViewReuseID];
        
        // 设置子标题和标题可以呼出
        annoView.canShowCallout = YES ;
        
        // 自定义左边的view
        annoView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
        // 自定义右边的View
        annoView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
    }
    
    return annoView ;
}

@end
