//
//  HYBBaiduMapHelper.m
//  BaiduMapDemo
//
//  Created by 黄仪标 on 14/11/18.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import "HYBBaiduMapHelper.h"

@interface HYBBaiduMapHelper () <BMKLocationServiceDelegate,
BMKGeneralDelegate,
BMKMapViewDelegate,
BMKRouteSearchDelegate> {
  BMKMapManager             *_mapManager;
  HYBUserLocationCompletion _locationCompletion;
  HYBRouteSearchCompletion  _routeSearchCompletion;
  BMKMapView                *_mapView;
  BMKLocationService        *_locationService;
  BMKRouteSearch            *_routeSearch;
}

@end

@implementation HYBBaiduMapHelper

+ (HYBBaiduMapHelper *)shared {
  static HYBBaiduMapHelper *baiduMapHelper = nil;
  static dispatch_once_t onceToken = 0;
  
  dispatch_once(&onceToken, ^{
    if (!baiduMapHelper) {
      baiduMapHelper = [[[self class] alloc] init];
    }
  });
  
  return baiduMapHelper;
}

- (instancetype)init {
  if (self = [super init]) {
    _mapManager = [[BMKMapManager alloc] init];
  }
  
  return self;
}

- (BOOL)startWithAppKey:(NSString *)appKey {
  if (![appKey isKindOfClass:[NSString class]] || appKey.length == 0 || appKey == nil) {
    return NO;
  }
  
  return [_mapManager start:appKey generalDelegate:self];
}

- (void)locateInView:(UIView *)mapSuerView frame:(CGRect)frame withCompletion:(HYBUserLocationCompletion)completion {
  _locationCompletion = [completion copy];
  
  [_locationService stopUserLocationService];
  _locationService = nil;
  _locationService.delegate = nil;
  _locationService = [[BMKLocationService alloc] init];
  [_locationService startUserLocationService];
  
  if (_mapView) {
    [_mapView removeFromSuperview];
    _mapView = nil;
  }
  _mapView.delegate = nil;
  _mapView.showsUserLocation = NO;
  _mapView = [[BMKMapView alloc] initWithFrame:frame];
  [mapSuerView addSubview:_mapView];
  
  _mapView.delegate = self;
  // 先关闭显示的定位图层
  _mapView.showsUserLocation = NO;
  // 设置定位的状态
  _mapView.userTrackingMode = BMKUserTrackingModeNone;
  _mapView.showsUserLocation = YES;
  return;
}

- (void)viewWillAppear {
  [_mapView viewWillAppear];
  
  _mapView.delegate = self;
  _locationService.delegate = self;
  _routeSearch.delegate = self;
  return;
}

- (void)viewWillDisappear {
  [_mapView viewWillDisappear];
  
  _mapView.delegate = nil;
  _locationService.delegate = nil;
  _routeSearch.delegate = nil;
  return;
}

- (void)viewDidDeallocOrReceiveMemoryWarning {
  [self viewWillDisappear];
  
  _mapView.showsUserLocation = NO;
  [_locationService stopUserLocationService];
  [_mapView removeFromSuperview];
  _mapView = nil;
  
  _locationService = nil;
  _routeSearch.delegate = nil;
  _routeSearch = nil;
  return;
}

///
/// 计算两点的距离
- (CLLocationDistance)distanceWithStartPoint:(CLLocationCoordinate2D)startPoint endPoint:(CLLocationCoordinate2D)endPoint {
  BMKMapPoint point1 = BMKMapPointForCoordinate(startPoint);
  BMKMapPoint point2 = BMKMapPointForCoordinate(endPoint);
  CLLocationDistance distance = BMKMetersBetweenMapPoints(point1, point2);
  return distance;
}

///
/// 下面的方法是路线规划获取操作
/// 公交检索方法
/// 前两个参数，分别表示起点和终点的位置名称
/// 第三个参数，表示在哪个城市里检索
- (void)transitRouteSearchFrom:(BMKPlanNode *)startNode
                            to:(BMKPlanNode *)endNode
                          city:(NSString *)city
                 transitPolicy:(BMKTransitPolicy)transitPolicy
                    completion:(HYBRouteSearchCompletion)completion {
  _routeSearchCompletion = [completion copy];
  
  if (_routeSearch == nil) {
    _routeSearch = [[BMKRouteSearch alloc] init];
  }
  
  _routeSearch.delegate = self;
  
  // 公交检索
  BMKTransitRoutePlanOption *transitRoutePlan = [[BMKTransitRoutePlanOption alloc] init];
  transitRoutePlan.city = city;
  transitRoutePlan.from = startNode;
  transitRoutePlan.to = endNode;
  transitRoutePlan.transitPolicy = transitPolicy;
  
  if ([_routeSearch transitSearch:transitRoutePlan]) {
    NSLog(@"bus检索发送成功");
  } else {
    NSLog(@"bus检索发送失败");
  }
  return;
}

/// 驾乘检索方法
/// 前两个参数，分别表示起点和终点的位置名称
- (void)driveRouteSearchFrom:(BMKPlanNode *)startNode
                          to:(BMKPlanNode *)endNode
                 drivePolicy:(BMKDrivingPolicy)drivePolicy
                  completion:(HYBRouteSearchCompletion)completion {
  _routeSearchCompletion = [completion copy];
  
  if (_routeSearch == nil) {
    _routeSearch = [[BMKRouteSearch alloc] init];
  }
  
  _routeSearch.delegate = self;
  
  // 公交检索
  BMKDrivingRoutePlanOption *driveRoutePlan = [[BMKDrivingRoutePlanOption alloc] init];
  driveRoutePlan.from = startNode;
  driveRoutePlan.to = endNode;
  driveRoutePlan.drivingPolicy = drivePolicy;
  
  if ([_routeSearch drivingSearch:driveRoutePlan]) {
    NSLog(@"drive 检索发送成功");
  } else {
    NSLog(@"drive 检索发送失败");
  }
  return;
}

/// 步行检索方法
/// 前两个参数，分别表示起点和终点的位置名称
- (void)walkRouteSearchFrom:(BMKPlanNode *)startNode
                         to:(BMKPlanNode *)endNode
                 completion:(HYBRouteSearchCompletion)completion {
  _routeSearchCompletion = [completion copy];
  
  if (_routeSearch == nil) {
    _routeSearch = [[BMKRouteSearch alloc] init];
  }
  
  _routeSearch.delegate = self;
  
  // 公交检索
  BMKWalkingRoutePlanOption *walkRoutePlan = [[BMKWalkingRoutePlanOption alloc] init];
  walkRoutePlan.from = startNode;
  walkRoutePlan.to = endNode;
  
  if ([_routeSearch walkingSearch:walkRoutePlan]) {
    NSLog(@"walk 检索发送成功");
  } else {
    NSLog(@"walk 检索发送失败");
  }
  return;
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError {
  if (0 == iError) {
    NSLog(@"联网成功");
  } else {
    NSLog(@"onGetNetworkState %d",iError);
  }
  return;
}

- (void)onGetPermissionState:(int)iError {
  if (0 == iError) {
    NSLog(@"百度地图授权成功");
  } else {
    NSLog(@"onGetPermissionState %d",iError);
  }
  return;
}

#pragma mark - BMKLocationServiceDelegate
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
  NSLog(@"location start");
  return;
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {
  NSLog(@"user location stop");
  return;
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
  NSLog(@"user derection change");
  [_mapView updateLocationData:userLocation];
  return;
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
  NSLog(@"didUpdateUserLocation lat %f,long %f",
        userLocation.location.coordinate.latitude,
        userLocation.location.coordinate.longitude);
  [_mapView updateLocationData:userLocation];
  if (_locationCompletion) {
    _locationCompletion(userLocation);
  }
  
  [_locationService stopUserLocationService];
  return;
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
  if (_locationCompletion) {
    _locationCompletion(nil);
  }
  
  [_locationService stopUserLocationService];
  return;
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetTransitRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKTransitRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error {
  if (error == BMK_SEARCH_NO_ERROR) { // 检索成功的处理
    for (BMKTransitRouteLine *line in result.routes) {
      NSLog(@"-----------------------------------------------------");
      NSLog(@"  时间：%2d %2d:%2d:%2d 长度: %d米",
            line.duration.dates,
            line.duration.hours,
            line.duration.minutes,
            line.duration.seconds,
            line.distance);
      for (BMKTransitStep *step in line.steps) {
        NSLog(@"%@     %@    %@    %@    %@",
              step.entrace.title,
              step.exit.title,
              step.instruction,
              (step.stepType == BMK_BUSLINE ? @"公交路段" : (step.stepType == BMK_SUBWAY ? @"地铁路段" : @"步行路段")),
              [NSString stringWithFormat:@"名称：%@  所乘站数：%d   全程价格：%d  区间价格：%d",
               step.vehicleInfo.title,
               step.vehicleInfo.passStationNum,
               step.vehicleInfo.totalPrice,
               step.vehicleInfo.zonePrice]);
      }
    }
    
    // 打车信息
    NSLog(@"打车信息------------------------------------------");
    NSLog(@"路线打车描述信息:%@  总路程: %d米    总耗时：约%f分钟  每千米单价：%f元  全程总价：约%d元",
          result.taxiInfo.desc,
          result.taxiInfo.distance,
          result.taxiInfo.duration / 60.0,
          result.taxiInfo.perKMPrice,
          result.taxiInfo.totalPrice);
    
    
  } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) { // 检索地址有岐义，可获取推荐地址
    // 获取建议检索起终点
    NSLog(@"无检索结果，返回了建议检索信息");
    
    NSLog(@"起点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.startPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
    
    NSLog(@"终点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.endPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
  } else {
    NSLog(@"无公交检索结果 ");
  }
  
  
  // 回调block根据实际需要返回，可修改返回结构
  if (_routeSearchCompletion) {
    _routeSearchCompletion(nil); // 这里只是返回空，这个需要根据实际需要返回
  }
  return;
}

- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKDrivingRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error {
  if (error == BMK_SEARCH_NO_ERROR) { // 检索成功的处理
    for (BMKDrivingRouteLine *line in result.routes) {
      NSLog(@"-----------------------------------------------------");
      NSLog(@"  时间：%2d %2d:%2d:%2d 长度: %d米",
            line.duration.dates,
            line.duration.hours,
            line.duration.minutes,
            line.duration.seconds,
            line.distance);
      for (BMKDrivingStep *step in line.steps) {
        NSLog(@"入口：%@   出口：%@   路段总体指示信息：%@    入口信息：%@    出口信息：%@  转弯数：%d",
              step.entrace.title,
              step.exit.title,
              step.instruction,
              step.entraceInstruction,
              step.exitInstruction,
              step.numTurns);
      }
    }
  } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) { // 检索地址有岐义，可获取推荐地址
    // 获取建议检索起终点
    NSLog(@"无检索结果，返回了建议检索信息");
    
    NSLog(@"起点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.startPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
    
    NSLog(@"终点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.endPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
  } else {
    NSLog(@"无公交检索结果 ");
  }
  
  
  // 回调block根据实际需要返回，可修改返回结构
  if (_routeSearchCompletion) {
    _routeSearchCompletion(nil); // 这里只是返回空，这个需要根据实际需要返回
  }
  return;
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKWalkingRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error {
  if (error == BMK_SEARCH_NO_ERROR) { // 检索成功的处理
    for (BMKDrivingRouteLine *line in result.routes) {
      NSLog(@"步行检索结果 ：-----------------------------------------------------");
      NSLog(@"  时间：%2d %2d:%2d:%2d 长度: %d米",
            line.duration.dates,
            line.duration.hours,
            line.duration.minutes,
            line.duration.seconds,
            line.distance);
      for (BMKWalkingStep *step in line.steps) {
        NSLog(@"入口：%@   出口：%@   路段总体指示信息：%@    入口信息：%@    出口信息：%@",
              step.entrace.title,
              step.exit.title,
              step.instruction,
              step.entraceInstruction,
              step.exitInstruction);
      }
    }
  } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) { // 检索地址有岐义，可获取推荐地址
    // 获取建议检索起终点
    NSLog(@"无检索结果，返回了建议检索信息");
    
    NSLog(@"起点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.startPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
    
    NSLog(@"终点推荐信息：--------------------------------");
    for (BMKPoiInfo *info in result.suggestAddrResult.endPoiList) {
      NSLog(@"POI名称:%@     POI地址:%@     POI所在城市:%@", info.name, info.address, info.city);
    }
  } else {
    NSLog(@"无公交检索结果 ");
  }
  
  
  // 回调block根据实际需要返回，可修改返回结构
  if (_routeSearchCompletion) {
    _routeSearchCompletion(nil); // 这里只是返回空，这个需要根据实际需要返回
  }
  return;
}

@end
