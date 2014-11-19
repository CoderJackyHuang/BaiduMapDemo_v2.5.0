//
//  HYBBaiduMapHelper.h
//  BaiduMapDemo
//
//  Created by 黄仪标 on 14/11/18.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"

typedef void (^HYBUserLocationCompletion)(BMKUserLocation *userLocation);
typedef void (^HYBRouteSearchCompletion)(BMKTransitRouteResult *result);

/*!
 * @brief 百度地图相关API操作类
 *
 * @author huangyibiao
 */
@interface HYBBaiduMapHelper : NSObject 

+ (HYBBaiduMapHelper *)shared;

///
/// 该方法在appdelegate的调用，在应用启动时，请求授权百度地图
- (BOOL)startWithAppKey:(NSString *)appKey;

///
/// 下面的几个方法是定位使用
- (void)locateInView:(UIView *)mapSuerView frame:(CGRect)frame withCompletion:(HYBUserLocationCompletion)completion;
- (void)viewWillAppear;
- (void)viewWillDisappear;
- (void)viewDidDeallocOrReceiveMemoryWarning;

///
/// 下面的方法是计算两地的距离
/// 返回距离单位为米
- (CLLocationDistance)distanceWithStartPoint:(CLLocationCoordinate2D)startPoint endPoint:(CLLocationCoordinate2D)endPoint;

///
/// 下面的方法是路线规划获取操作
///

/// 公交检索方法
/// 前两个参数，分别表示起点和终点的位置名称
/// 第三个参数，表示在哪个城市里检索
- (void)transitRouteSearchFrom:(BMKPlanNode *)startNode
                            to:(BMKPlanNode *)endNode
                          city:(NSString *)city
                 transitPolicy:(BMKTransitPolicy)transitPolicy
                    completion:(HYBRouteSearchCompletion)completion;

@end
