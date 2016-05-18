//
//  FDSportViewController.m
//  Runer
//
//  Created by tarena on 16/5/18.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDSportViewController.h"
#import "BMapKit.h"
typedef enum {
    TrailStare = 1,
    TrailEnd
}Trail;
@interface FDSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
/**
 *  完成按钮被点击
 */
- (IBAction)completeBtnClick:(id)sender;
/**
 *  继续按钮被点击
 */
- (IBAction)continueBtnClick:(id)sender;
/**
 *  开始运动的按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *StartBtn;
/**
 *  暂停按钮被点击
 */
@property (weak, nonatomic) IBOutlet UIButton *stopRunBtn;
/**
 * 开始按钮被点击
 */
- (IBAction)startBtnClick:(id)sender;
@property BMKMapView *mapView;
/**
 *  暂停按钮的视图
 */
@property (weak, nonatomic) IBOutlet UIView *pauseSportView;
/**
 *  定位服务
 */

@property (nonatomic, strong) BMKLocationService *location;
//起点大头针
@property (nonatomic, strong) BMKPointAnnotation *startPoint;
//终点大头针
@property (nonatomic, strong) BMKPointAnnotation *endPoint;
//标记划线还是不画线
@property (nonatomic, assign) Trail trail;
/**
 *  用来储蓄用户位置的数据
 */
@property (nonatomic, strong) NSMutableArray *lotationArray;
/**
 *  遮盖线
 */
@property (nonatomic, strong) BMKPolyline *pokyline;
/**
 *  记录用户上一个位置
 */
@property (nonatomic, strong) CLLocation *preLocation;
/**
 *  运动的总距离 实时
 */
@property (nonatomic, assign) double sumDistance;
@end
//一个扇区所跨的经纬度
#define BMKSPAN 0.002//20米
@implementation FDSportViewController
- (NSMutableArray *)lotationArray{
    if (_lotationArray== nil) {
        _lotationArray = [NSMutableArray array];
    }return _lotationArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.trail = TrailEnd;
    self.mapView = [BMKMapView new];
    self.mapView.frame = self.view.bounds;
    [self.view insertSubview:self.mapView atIndex:0];
    [self setupBMKLocationServer];
    [self setMapViewProperty];
    self.mapView.delegate = self;
    self.location.delegate = self;
    [self.location startUserLocationService];
    //给暂停按钮添加手势识别
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(pauseSport)];
    gesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.stopRunBtn addGestureRecognizer:gesture];
    
}

- (void)pauseSport{
    //先隐藏暂停按钮
    self.stopRunBtn.hidden = YES;
    //停止位置服务
    [self.location stopUserLocationService];
    //显示暂停视图
    self.pauseSportView.hidden = NO;
}
#pragma mark -- 设置起点和终点
- (IBAction)startBtnClick:(id)sender {
    self.StartBtn.hidden = YES;
    self.stopRunBtn.hidden = NO;
    //添加大头针
    self.startPoint = [self createPointWithLocation:self.location.userLocation.location title:@"起点"];
    //将起点添加到数组中 增加划线的精确度
    [self.lotationArray addObject:self.location.userLocation.location];
}
/**
 *  创建大头针
 */
- (BMKPointAnnotation *)createPointWithLocation:(CLLocation *)location title:(NSString *)title{
    BMKPointAnnotation *point = [BMKPointAnnotation new];
    point.coordinate = location.coordinate;
    [self.mapView addAnnotation:point];
    return point;
}
/**
 *  设置大头针的view
 */
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    if (![annotation isKindOfClass:[BMKPinAnnotationView class]]) {
        //如果起点大头针有值 就设置为终点的图片
        BMKPinAnnotationView *anotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        if (self.startPoint) {
            anotationView.image = [UIImage imageNamed:@"定位-终"];
        }else{
            anotationView.image = [UIImage imageNamed:@"定位-起"];
        }
        anotationView.animatesDrop = YES;
        anotationView.draggable = YES;
        return anotationView;
    }
    return nil;
    
}
- (void)setupBMKLocationServer{
    self.location = [BMKLocationService new];
        //设置过滤
    [BMKLocationService setLocationDistanceFilter:6];//移动六米就定位
    //定位精度 最高精度
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}
- (void)setMapViewProperty{
    /**
     显示定位图层
     */
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = NO;
    self.mapView.showMapScaleBar = YES;
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    //设置图层自定义样式参数
    BMKLocationViewDisplayParam *displayParame = [BMKLocationViewDisplayParam new];
    displayParame.isAccuracyCircleShow = YES;
    //小圆点的偏移量 可以纠正地图的偏移
    displayParame.locationViewOffsetX = 0;
    displayParame.locationViewOffsetY = 0;
}
/**
 *  用户的位置更新
 */
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"%f,%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude);
    [self.mapView updateLocationData:userLocation];
    //获取一个合理的范围
    BMKCoordinateRegion fitsRagin = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(BMKSPAN, BMKSPAN))];
    [self.mapView  setRegion:fitsRagin];
    //定位的准确性
    if (userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        //用户没在室外 因为定位精确度不够
        NSLog(@"请到室外");
        return;
    }else{
        //启动位置跟踪 用户的运动路径
        [self startTralRouterLocation:userLocation];
    }
    
}
#pragma mark 处理用户位置
- (void)startTralRouterLocation:(BMKUserLocation *)location{
    //计算运动的总距离 实时计算距离
    if (self.preLocation) {
        double distance = [self.preLocation distanceFromLocation:location.location];
        self.sumDistance += distance;
    }self.preLocation = location.location;
    //把当前位置放入位置数组
    [self.lotationArray addObject:location.location];
    //绘制用户路径
    [self drawWalkLine];
}
-(void)drawWalkLine{
    NSInteger count = self.lotationArray.count;
    //需要把数组中的位置转化成BMKPoint
    BMKMapPoint *tempPoint = malloc(sizeof(BMKMapPoint)*count);
    [self.lotationArray enumerateObjectsUsingBlock:^(CLLocation * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        tempPoint[idx] = point;
    }];
    self.pokyline = [BMKPolyline polylineWithPoints:tempPoint count:count];
    //添加遮盖物
    if (self.pokyline) {
        [self.mapView addOverlay:self.pokyline];
    }free(tempPoint);//结构体 不是oc语言 需要手动释放
    
}
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *poluLineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        poluLineView.strokeColor = [UIColor greenColor];
        poluLineView.lineWidth = 3.0;
        return poluLineView;
        
    }return nil;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)StopBtnClick:(id)sender {
  
}

- (IBAction)completeBtnClick:(id)sender {
}

- (IBAction)continueBtnClick:(id)sender {
}
@end
