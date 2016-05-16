//
//  FDMessageViewController.m
//  Runer
//
//  Created by tarena on 16/5/14.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDMessageViewController.h"
#import "XMPPMessage.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "FDMeTableViewCell.h"
#import "FDOtherTableViewCell.h"
#import "XMPPvCardTemp.h"
@interface FDMessageViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTield;
//结构集控制器
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)senfTextMessage:(id)sender;

@end

@implementation FDMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //行高自适应====必须要给这两行
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //预估值
    self.tableView.estimatedRowHeight = 80;
    
    
    [self loadMesage];
}
//使table滚动到最后
-(void)scrollerTOTableViewLastRow{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return;
    }else{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0];
    //TableView 底部滚动到最后一行
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

//添加监听键盘出现和收回的通知
- (void)viewWillAppear:(BOOL)animated{
      [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    self.title = self.friendJid.user;
    
     [self scrollerTOTableViewLastRow];
}
//键盘弹出
- (void)showKeyboard:(NSNotification *)notification{

        NSTimeInterval duration = [notification.userInfo[UIKeyboardWillHideNotification]doubleValue];
        NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
        CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
        CGFloat height = rect.size.height;
        self.buttomTextView.constant = height;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 50)];
        self.inputTield.leftViewMode = UITextFieldViewModeAlways;
        self.inputTield.leftView = imageView;
    
//    [UIView animateKeyframesWithDuration:duration delay:0 options:option animations:^{
//        [self.view layoutIfNeeded];
//        
////        [self scrollerTOTableViewLastRow];表格向上移动
//    } completion:nil];
    //第二种动画模式
   [UIView animateWithDuration:duration delay:0 options:option animations:^{
       [self.view layoutIfNeeded];
       [self scrollerTOTableViewLastRow];//表格向上移动
   } completion:nil];
}
//键盘收起
- (void)closeKeyboard:(NSNotification *)notification{
    //键盘弹起的持续时间
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    //键盘弹起动画的类型
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    //将输入框view移动到初始位置
    self.buttomTextView.constant = 0;
    [UIView animateKeyframesWithDuration:duration delay:0 options:option animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}
#pragma mark  -- 加载消息
- (void)loadMesage{
    //获取上下文
    NSManagedObjectContext *context = [[FDXMPPTool sharedFDXMPPTool].xmppMessageArchivingStore mainThreadManagedObjectContext];
    //关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //设置谓词
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",[FDUserInfo sharedFDUserInfo].jidStr,[self.friendJid bare]];//jib 为str
    request.predicate =pre;
    //设置排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sortDes];
    //获取数据
    NSError *error = nil;
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error%@",error);
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)senfTextMessage:(id)sender {
    //获取要发送的数据
    NSString *msgStr = self.inputTield.text;
    self.inputTield.text = nil;
    [self.inputTield becomeFirstResponder];
    //组装一个消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //组装消息
    [msg addBody:msgStr];
    [[FDXMPPTool sharedFDXMPPTool].xmppStream sendElement:msg];
}

#pragma mark -- tabledelegate dataDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedResultsController.fetchedObjects.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取信息对象
    XMPPMessageArchiving_Message_CoreDataObject *msageObj = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if (msageObj.isOutgoing) {
        FDMeTableViewCell *meCell = [tableView dequeueReusableCellWithIdentifier:@"meCell"];
        meCell.msgLabel.text = msageObj.body;
        NSData *data = [FDXMPPTool sharedFDXMPPTool].xmppvCard.myvCardTemp.photo;
        if (data) {
            meCell.headImageView.image = [UIImage imageWithData:data];
        }else{
            meCell.imageView.image = [UIImage imageNamed:@"瓦力"];
        }
        meCell.msgTimeLabel.text = @"2016-06-01";
        return meCell;
    }else{
        FDOtherTableViewCell *otherCell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
        
    otherCell.magLabel.text = msageObj.body;
    otherCell.timeTextLabel.text = @"2015.02.01";
    otherCell.userNameLabel.text = @"sf";
    return otherCell;
    }
}




//结果集
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    [self scrollerTOTableViewLastRow];
}











@end
