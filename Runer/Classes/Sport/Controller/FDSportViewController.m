//
//  FDSportViewController.m
//  Runer
//
//  Created by tarena on 16/5/18.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDSportViewController.h"
#import "BMapKit.h"
#import "FDUserInfo.h"
#import "NSString+md5.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "MBProgressHUD+KR.h"
typedef enum {
    TrailStare = 1,
    TrailEnd
}Trail;
@interface FDSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>

 //////跑步完成
/**
 *分享到sina微博
 */
- (IBAction)sharedToSInaWeiBo:(id)sender;
/**
 *  分享到酷跑
 */
- (IBAction)sharedToRuner:(id)sender;
/**
 *  保存按钮
 */
- (IBAction)saveBtnClick:(id)sender;
/**
 *  取消保存按钮
 */
- (IBAction)cancelBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *completetSportView;
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

/**
 *  运动总距离
 */
@property (nonatomic, assign) int sumDistance;
/**
 *  运动总时间
 */
@property (nonatomic, assign)  double sumSportTimeLen;

/**
 *  运动总热量
 */
@property (nonatomic, assign) double sumSportHear;
/**
 *  运动开始时间
 */
@property (nonatomic, assign) double sumSportTime;
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
    
    //启动的时候 分享视图是隐藏的
    self.completetSportView.hidden = YES;
    
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

//划线
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
    
    //每次划线前 需要移除之前的划线
//    if (self.pokyline) {
//        [self.mapView removeOverlay:self.pokyline];
//    }
    
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
    //先把暂停视图隐藏
    self.pauseSportView.hidden = YES;
    //设置终点大头针
    self.endPoint = [self createPointWithLocation:[self.lotationArray lastObject] title:@"终点"];
    //把所有的点显示在屏幕范围内
    
    [self fitMapViewForPolyLine:self.pokyline];
    
    self.completetSportView.hidden = NO;
    // 准备需要的数据
    CLLocation *firstLoc = [self.lotationArray firstObject];
    CLLocation *lastLoc  = [self.lotationArray lastObject];
    self.sumSportTimeLen = [lastLoc.timestamp timeIntervalSince1970] - [firstLoc.timestamp timeIntervalSince1970];
    // 根据这个人的体重 和 运动方式 运动时间
    self.sumSportHear = (self.sumSportTimeLen/3600.0) * 600.0;
    // 运动开始的时间
    self.sumSportTime = [firstLoc.timestamp timeIntervalSince1970];
}

- (IBAction)continueBtnClick:(id)sender {
    self.stopRunBtn.hidden = YES;
    self.pauseSportView.hidden = YES;
    self.stopRunBtn.hidden = NO;
    [self.location startUserLocationService];
}
#pragma mark -- 把所有的点显示在屏幕上
- (void) fitMapViewForPolyLine:(BMKPolyline*) polyline{
    CGFloat ltX,ltY,maxX,maxY;
    if (polyline.pointCount < 2) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    ltX = pt.x, ltY = pt.y;
    maxX = pt.x, maxY = pt.y;
    for (int i = 0; i < polyline.pointCount; i++) {
        BMKMapPoint innerPt = polyline.points[i];
        if (innerPt.x < ltX) {
            ltX = innerPt.x;
        }
        if (innerPt.y < ltY) {
            ltY = innerPt.y;
        }
        if (innerPt.x > maxX) {
            maxX = innerPt.x;
        }
        if (innerPt.y > maxY) {
            maxY = innerPt.y;
        }
    }
    // 根据点的分布 构建一个矩形
    BMKMapRect rect ;
    rect.origin = BMKMapPointMake(ltX - 40, ltY - 60);
    rect.size = BMKMapSizeMake((maxX - ltX) + 80, (maxY - ltY) + 120);
    [self.mapView setVisibleMapRect:rect];
}


- (IBAction)sharedToRuner:(id)sender {
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/addTopic.jsp",FDXMPPPHOSTNAME];
    NSMutableDictionary *paramenters = [NSMutableDictionary new];
    paramenters[@"username"] = [FDUserInfo sharedFDUserInfo].userName;
    paramenters[@"md5password"] = [[FDUserInfo sharedFDUserInfo].userpassword md5Str1];
    NSString *dataStr = [NSString stringWithFormat:@"本次运动的总距离%.1d米,运动的总时间%.1lf秒,消耗的总热量%.4lf卡",self.sumDistance,self.sumSportTimeLen,self.sumSportHear];
    paramenters[@"content"] = dataStr;
    paramenters[@"address"] = @"中国北京";
    // 最后一个点的经纬度
    CLLocation *lastLoc = [self.lotationArray lastObject];
    paramenters[@"latitude"] = @(lastLoc.coordinate.latitude);
    paramenters[@"longitude"] = @(lastLoc.coordinate.longitude);
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    [manger POST:url parameters:paramenters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *image = [self.mapView takeSnapshot];
        // 宽度是200  高度是等比例的
        double s = 200.0/image.size.width;
    UIImage *newImage = [self thumbaiWithImage:image size:CGSizeMake(100, s*image.size.height)];
        //以时间和当前用户来产生用户名
        NSDate *date = [NSDate date];
        NSDateFormatter *matter = [NSDateFormatter new];
        matter.dateFormat  = @"YYMMDDhh:mm:ss ";
        NSString *dateStr = [matter stringFromDate:date];
        NSString *fileName = [NSString stringWithFormat:@"%@%@.png",dateStr,[FDUserInfo sharedFDUserInfo].userName];
        [formData appendPartWithFileData:UIImagePNGRepresentation(newImage) name:@"pic" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"success %@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"failure:%@",error.userInfo);
    }];
}

//压缩图片
- (UIImage *) thumbaiWithImage:(UIImage *)image size:(CGSize)size {
    UIImage *newImage = nil;
    if (image) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return newImage;
    
}

- (IBAction)saveBtnClick:(id)sender {
    [self saveDataToWebServer];
    //调用清理按钮
    [self cancelBtnClick:nil];
}

- (IBAction)cancelBtnClick:(id)sender {
    
    self.StartBtn.hidden = NO;
    self.completetSportView.hidden = YES;
    //清理运动距离,运动时间,运动总热量,地图上的大头针,地图上 的线
    //清空数组数据
    [self.lotationArray removeAllObjects];
    //移除大头针
    if (self.startPoint) {
        [self.mapView removeAnnotation:self.startPoint];
        self.startPoint = nil;
    }
    if (self.endPoint) {
        [self.mapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
    //移除遮盖物
    if (self.pokyline) {
        [self.mapView removeAnnotation:self.pokyline];
        self.pokyline = nil;
    }
    [self.location startUserLocationService];
    
}
- (IBAction)sharedToSInaWeiBo:(id)sender {
    //如果不是微博的登录就拒绝
    if ([FDUserInfo sharedFDUserInfo].sinaLogin) {
        NSString *url = @"https://upload.api.weibo.com/2/statuses/upload.json";
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"access_token"] = [FDUserInfo sharedFDUserInfo].userpassword;
        NSString *status = [NSString stringWithFormat:@"这是一条来自Runer的测试微博,我的位置是"];
        parameters[@"lat"] = @"28.982";
        parameters[@"long"] = @"118.844";
        parameters[@"status"] = status;
        AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
        [manger POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //发布图片
            UIImage *image = [self.mapView takeSnapshot];
            [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"pic" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"发布成功%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        
    }else{
        [MBProgressHUD showError:@"请用sina微博登录"];
    }
    
}

//将数据发送到web 服务器
- (void)saveDataToWebServer{
    MYLog(@"把数据存入web服务器");
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/addSportData.jsp",FDXMPPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [FDUserInfo sharedFDUserInfo].userName;
    parameters[@"md5password"] = [[FDUserInfo sharedFDUserInfo].userpassword md5Str1];
    // 运动类型 1 代表自行车  2 跑步
    // 3 滑雪  4 散步
    parameters[@"sportType"] = @(2);
    // 运动的总距离 总时间 总热量 开始时间
    parameters[@"sportDistance"] = @(self.sumDistance);
    parameters[@"sportTimeLen"] = @(self.sumSportTimeLen);
    parameters[@"sportHeat"] = @(self.sumSportHear);
    parameters[@"sportStartTime"] = @(self.sumSportTimeLen);
    // 还有最后一个参数 data 这个参数的构成是这样的  经度|纬度|开始时间@经度|纬度|开始时间
    parameters[@"data"] = @"116.9|39.4|1232342@116.5|39.1|1233343";
    // 使用AFN 发送这个请求
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    [manger POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}










@end
