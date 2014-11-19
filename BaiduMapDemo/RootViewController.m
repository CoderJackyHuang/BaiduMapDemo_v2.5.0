//
//  RootViewController.m
//  BaiduMapDemo
//
//  Created by 黄仪标 on 14/11/18.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import "RootViewController.h"
#import "HYBBaiduMapHelper.h"
#import "BMapKit.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 功能1、定位
  [[HYBBaiduMapHelper shared] locateInView:self.view frame:self.view.bounds withCompletion:^(BMKUserLocation *userLocation) {
    NSLog(@"%f  %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
  }];
  
  // 功能2：”计算距离
 CLLocationDistance distance = [[HYBBaiduMapHelper shared] distanceWithStartPoint:CLLocationCoordinate2DMake(39.915,116.404)
                                            endPoint:CLLocationCoordinate2DMake(38.915,115.404)];
  NSLog(@"distance = %fm", distance);
  
  // 功能3：公交检索
  BMKPlanNode *startNode = [[BMKPlanNode alloc] init];
  startNode.name = @"梆子井";
  startNode.cityName = @"北京";
  
  BMKPlanNode *endNode = [[BMKPlanNode alloc] init];
  endNode.name = @"金长安大厦";
  endNode.cityName = @"北京";
  
  // 功能3：公交检索
  [[HYBBaiduMapHelper shared] transitRouteSearchFrom:startNode to:endNode city:@"北京" transitPolicy:BMK_TRANSIT_TRANSFER_FIRST completion:^(BMKTransitRouteResult *result) {
    // 功能4：驾乘检索
    [[HYBBaiduMapHelper shared] driveRouteSearchFrom:startNode to:endNode drivePolicy:BMK_DRIVING_TIME_FIRST  completion:^(BMKTransitRouteResult *result) {
      // 功能5：步行检索
      [[HYBBaiduMapHelper shared] walkRouteSearchFrom:startNode to:endNode completion:^(BMKTransitRouteResult *result) {
        ;
      }];
    }];
  }];
  return;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[HYBBaiduMapHelper shared] viewWillAppear];
  
  return;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[HYBBaiduMapHelper shared] viewWillDisappear];
  return;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
  [[HYBBaiduMapHelper shared] viewDidDeallocOrReceiveMemoryWarning];
  return;
}

- (void)dealloc {
  [[HYBBaiduMapHelper shared] viewDidDeallocOrReceiveMemoryWarning];
  return;
}


@end
