//
//  FDFirendListTableViewController.m
//  Runer
//
//  Created by tarena on 16/5/13.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDFirendListTableViewController.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "FDFriendTableViewCell.h"
@interface FDFirendListTableViewController ()<NSFetchedResultsControllerDelegate>
- (IBAction)backBtnClick:(id)sender;
//存放好友列表
//@property (nonatomic, strong) NSArray *friends;
//结果集
@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;
@end

@implementation FDFirendListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFiends2];
}
//加载好友
- (void)loadFiends{
    //1.获取上下文
    NSManagedObjectContext *context = [[FDXMPPTool sharedFDXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    
    //2.NSFetchRequest 关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置谓词()过滤 NSPredicate
    NSString *jibStr = [NSString stringWithFormat:@"%@@%@",[FDUserInfo sharedFDUserInfo].userName,FDXMPPDOMAIN];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jibStr];
    request.predicate = pre;
    
    //4.设置排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sortDes];
    //5.获取数据
    NSError *error = nil;
//    self.friends = [context executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
    
}
- (void)loadFiends2{
    //1.获取上下文
    NSManagedObjectContext *context = [[FDXMPPTool sharedFDXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    
    //2.NSFetchRequest 关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置谓词()过滤 NSPredicate
    NSString *jibStr = [NSString stringWithFormat:@"%@@%@",[FDUserInfo sharedFDUserInfo].userName,FDXMPPDOMAIN];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jibStr];
    request.predicate = pre;
    
    //4.设置排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sortDes];
    //5.获取数据
    NSError *error = nil;
    self.fetchedResultsController  = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:&error];
//    self.friends = [context executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
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

    return self.fetchedResultsController.fetchedObjects.count;
}

#pragma mark NDFetchenResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   FDFriendTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    //获取好友对应的数据
    
    XMPPUserCoreDataStorageObject *friend = self.fetchedResultsController.fetchedObjects[indexPath.row];
    cell.friendNameLabel.text = friend.displayName;
    //获取头像信息
    
    NSData *data = [[FDXMPPTool sharedFDXMPPTool].xmppvCardAvatar photoDataForJID:friend.jid];
    if (data) {
        cell.friendHeadiamgeView.image = [UIImage imageWithData:data];
    }else{
        cell.friendHeadiamgeView.image = [UIImage imageNamed:@"瓦力"];
    }
    //获取好友在线状态 0 在线1 离开 2
    switch (friend.sectionNum.integerValue) {
        case 0:
            cell.friendsStatusLabel.text = @"在线";
            cell.friendsStatusLabel.textColor = [UIColor greenColor];
            break;
        case 1:
            cell.friendsStatusLabel.text = @"离开";
            cell.friendsStatusLabel.textColor = [UIColor purpleColor];
            break;
        case 2:
            cell.friendsStatusLabel.text = @"离线";
            cell.friendsStatusLabel.textColor = [UIColor grayColor];
            break;
        default:
            break;
    }

    return cell;
}
/**
 *  删除模式
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //调用删除对应好友方法
        [[FDXMPPTool sharedFDXMPPTool].xmppRoster removeUser:friend.jid];
        //设置删除后的效果
//         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}











- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
