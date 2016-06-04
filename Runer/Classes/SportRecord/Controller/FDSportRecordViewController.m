//
//  FDSportRecordViewController.m
//  Runer
//
//  Created by tarena on 16/5/20.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDSportRecordViewController.h"
#import "FDUserInfo.h"
#import "FDXMPPTool.h"
#import "XMPP.h"
#import "AFHTTPRequestOperationManager.h"
#import "FDSportRecord.h"
#import "FDSportRecordCell.h"
#import "NSString+md5.h"
@interface FDSportRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

- (IBAction)backBtnClick:(id)sender;
/**
 *  之前选中的
 */
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
/**
 *  当前的选中的
 */
@property (nonatomic, strong) UIButton *selectedBtn;
/**
 *  存储运动迷行对象数据
 */
@property (nonatomic, strong) NSMutableArray *sportRecordData;
/**
 *  显示运动数据
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FDSportRecordViewController




- (IBAction)chooseSportModel:(UIButton *)sender {
    if (sender == self.selectedBtn) {
        return;
    }
    self.preBtn = self.selectedBtn;
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.preBtn.selected = NO;
    [self loadSportDataFromWebServerWithType:sender.tag];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //默认当前选中的指向之前的
    self.selectedBtn = self.preBtn;
    //给模型数据开辟空间
    self.sportRecordData = [NSMutableArray array];
    //默认加载跑步型数据
    [self loadSportDataFromWebServerWithType:FDSportModelBick];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"nill");
}
/**
 *  根据模式选择 加载数据
 */
- (void)loadSportDataFromWebServerWithType:(enum FDSportModel)type{
    NSString *str = @"http://172.60.21.125:8080/allRunServer/queryUserDataByType.jsp";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [FDUserInfo sharedFDUserInfo].userName;
    parameters[@"md5password"] = [[FDUserInfo sharedFDUserInfo].userpassword md5Str1];
    parameters[@"sportType"] = @(type);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:str parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
        NSArray *array = responseObject[@"sportData"];
        //清空数组中之前的数据
        [self.sportRecordData removeAllObjects];
        // 把字典数组转成模型数组
        for(int i = 0; i < array.count; i++){
            FDSportRecord *rec = [FDSportRecord new];
            // KVC
            [rec setValuesForKeysWithDictionary:array[i]];
            [self.sportRecordData addObject:rec];
        }
        // 刷新表格显示数据
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
    
}
- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sportRecordData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDSportRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordCell" forIndexPath:indexPath];
    FDSportRecord *rec = self.sportRecordData[indexPath.row];
    cell.sportRecordDistance.text = rec.sportDistance;
    cell.soprtRecordHot.text = @"test";
    //运动时间和图片
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:rec.sportStartTime.doubleValue];
    NSDateFormatter *matter = [NSDateFormatter new];
    matter.dateFormat = @"yy-MM-dd mm:hh:ss";
    cell.sportRecordTime.text = [matter stringFromDate:date];
    cell.sportImageView.image = [UIImage imageNamed:[self getImageNageBySportType:rec.sportType]];
    return cell;
}


/**
 *  根据运动类型返回图片名
 */
- (NSString *)getImageNageBySportType:(enum FDSportModel)type{
    NSString *imageName = nil;
    switch (type) {
        case FDSportModelBick:
            imageName = @"select1";
            break;
        case FDSportModelRun:
            imageName = @"select2";
            break;
        case FDSportModelSkiing:
            imageName = @"select3";
            break;
        default:
            imageName = @"select4";
            break;
    }
    return imageName;
}







@end
