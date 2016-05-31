//
//  ViewController.m
//  BaiduMap
//
//  Created by 范胜利 on 16/5/31.
//  Copyright © 2016年 Soley. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>

@property (nonatomic,strong)BMKMapView * mapView;
@property (nonatomic,strong)BMKLocationService *locService;

@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated {
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地图";
    self.locService = [[BMKLocationService alloc]init];
    [self createUI];
}

- (void)createUI{
    self.mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.zoomLevel = 16;
    [self.view addSubview:self.mapView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 300, 15, 15);
    [button setBackgroundColor:[UIColor yellowColor]];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)btnClick:(UIButton *)sender{
    NSLog(@"点击啦");
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //判断是否开启定位
        [self judgeStates];
    }
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    [self.locService startUserLocationService];
}

- (void)judgeStates{
    //设置提醒开启定位
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请去系统定位服务,允许***获取您的位置" message:@"打开定位服务" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL*url=[NSURL
                   URLWithString:@"prefs:root=LOCATION_SERVICES"];
        [[UIApplication sharedApplication] openURL:url];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - BMKMapViewDelegate
/**
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    
    [self.mapView setCompassPosition:CGPointMake(0,40)];
    NSString *longitudeString=[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    NSString *latitudeString=[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    NSLog(@"longitudeString = %@  latitudeString = %@",longitudeString,latitudeString);
}
/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSString *longitudeString=[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    NSString *latitudeString=[NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    NSLog(@"longitudeString = %@  latitudeString = %@",longitudeString,latitudeString);
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    [_mapView updateLocationData:userLocation];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"location error");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
