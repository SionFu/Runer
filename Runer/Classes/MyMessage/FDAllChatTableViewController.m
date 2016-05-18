//
//  FDAllChatTableViewController.m
//  Runer
//
//  Created by tarena on 16/5/17.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDAllChatTableViewController.h"
#import "XMPPMessage.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "XMPPvCardTemp.h"
#import "FDMessageViewController.h"
#import "FDMyMessageCell.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
@interface FDAllChatTableViewController ()
@property (nonatomic, strong) NSArray *mostRecentMsg;
- (IBAction)backBtnClick:(id)sender;

@end

@implementation FDAllChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMostRecentMsg];
}
- (void)loadMostRecentMsg{
    //获取上下文
    NSManagedObjectContext *context = [[FDXMPPTool sharedFDXMPPTool].xmppMessageArchivingStore mainThreadManagedObjectContext];
    //关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    //设置谓词
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[FDUserInfo sharedFDUserInfo].jidStr];
    request.predicate = pre;
    //设置排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    request.sortDescriptors = @[sortDes];
    //获取数据
    NSError *error = nil;
    self.mostRecentMsg = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.mostRecentMsg.count;
}

//设置表格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDMyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    //获取消息模型对象
    
    XMPPMessageArchiving_Contact_CoreDataObject *object = self.mostRecentMsg[indexPath.row];
    NSData *photo = [[FDXMPPTool sharedFDXMPPTool].xmppvCardAvatar photoDataForJID:object.bareJid];
    if (photo) {
        cell.headImageView.image = [UIImage imageWithData:photo];
    }else{
    cell.headImageView.image = [UIImage imageNamed:@"瓦力"];
    }
    cell.userNameLabel.text = object.bareJidStr;
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    dateformatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
    //设置时间
    cell.mssageTimeLabel.text = [dateformatter stringFromDate:object.mostRecentMessageTimestamp];
    //设置表格聊天内容
    if ([object.mostRecentMessageBody hasPrefix:@"text"]) {
        cell.massageLabel.text = [object.mostRecentMessageBody substringFromIndex:5];
    }else{
        cell.massageLabel.text = @"图片";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取对应这一行的好友信息
    XMPPMessageArchiving_Message_CoreDataObject *friend = self.mostRecentMsg[indexPath.row];
    [self performSegueWithIdentifier:@"gotoChat" sender:friend.bareJid];
}

//让聊天视图接受 好友的jid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVC = segue.destinationViewController;
    //判断是否为这个控制器
    if ([destVC isKindOfClass:[FDMessageViewController class]]) {
        FDMessageViewController *messageVC = (FDMessageViewController *)destVC;
        messageVC.friendJid = sender;
    }
    
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
