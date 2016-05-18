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
#import "FDFriendInfoViewController.h"
@interface FDMessageViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *msgLabel;
- (IBAction)friendInfoBtnClick:(id)sender;

- (IBAction)iamgeBtnClick:(id)sender;
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
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.inputTield.leftViewMode = UITextFieldViewModeAlways;
    self.inputTield.leftView = imageView;
    //行高自适应====必须要给这两行
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //预估值
    self.tableView.estimatedRowHeight = 80;
    [self.msgLabel becomeFirstResponder];
    
    [self loadMesage];
}
#pragma mark  -- 使table滚动到最后
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
    //聊天内容滚动到最后一行
    [self scrollerTOTableViewLastRow];

}
//键盘弹出
- (void)showKeyboard:(NSNotification *)notification{

        NSTimeInterval duration = [notification.userInfo[UIKeyboardDidHideNotification]doubleValue];
        NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
        CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
        CGFloat height = rect.size.height;
        self.buttomTextView.constant = height;
        [self.tableView layoutIfNeeded];
    
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
    [self scrollerTOTableViewLastRow];//表格向上移动
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
    [msg addBody:[NSString stringWithFormat:@"text:%@",msgStr]];
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
        //方法一
//        if ([[meCell.msgLabel.subviews lastObject]isKindOfClass:[UIImageView class]]) {
//            [[meCell.msgLabel.subviews lastObject]removeFromSuperview];
//        }
        /**
         *  方法二
         */
        [[meCell.msgLabel viewWithTag:100]removeFromSuperview];
        
        //移除复用组件 方法三
//        meCell.msgLabel.attributedText = nil;
//        for (id obj in meCell.msgLabel.subviews) {
//            [obj removeFromSuperview];
//        }
        if ([msageObj.body hasPrefix:@"text:"]) {
            meCell.msgLabel.text = [msageObj.body substringFromIndex:5];
        }else if ([msageObj.body hasPrefix:@"image:"]){
            NSString *base64 = [msageObj.body substringFromIndex:6];
            //把base64 转换 成data
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:base64 options:0];
            //使用uilabel 富文本
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.bounds = CGRectMake(0, 0, 110, 110);
            //副文本
            NSAttributedString *attributedStr = [NSAttributedString attributedStringWithAttachment:attachment];
            meCell.msgLabel.attributedText = attributedStr;
            //构建一个uiimageView
            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:imageData]];
            [meCell.msgLabel addSubview:imageView];
            imageView.tag = 100;
        }
        else{
            //兼容以前的消息
            meCell.msgLabel.text = msageObj.body;
        }
        
        NSData *data = [FDXMPPTool sharedFDXMPPTool].xmppvCard.myvCardTemp.photo;
        if (data) {
            //设置为圆形头像
            [meCell.headImageView setRoundlay];
            meCell.headImageView.image = [UIImage imageWithData:data];
        }else{
            meCell.imageView.image = [UIImage imageNamed:@"瓦力"];
        }
        meCell.msgTimeLabel.text = @"2016-06-01";
        meCell.userNageLabel.text = [FDUserInfo sharedFDUserInfo].userName;
        return meCell;
    }
    
    else
    
    {
        FDOtherTableViewCell *otherCell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
        
        //消除表格的重用
        [[otherCell.magLabel viewWithTag:120]removeFromSuperview];
        
        //显示消息文本内容 包括头像和文本
        if ([msageObj.body hasPrefix:@"text:"]) {
            otherCell.magLabel.text = [msageObj.body substringFromIndex:5];
        }else if ([msageObj.body hasPrefix:@"image:"]){
            NSString *base64 = [msageObj.body substringFromIndex:6];
            //把base64 转换 成data
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:base64 options:0];
            //使用uilabel 富文本
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.bounds = CGRectMake(0, 0, 110, 110);
            //副文本
            NSAttributedString *attributedStr = [NSAttributedString attributedStringWithAttachment:attachment];
            otherCell.magLabel.attributedText = attributedStr;
            //构建一个uiimageView
            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:imageData]];
            imageView.tag = 120;
            [otherCell.magLabel addSubview:imageView];
        }
        //显示头像
        NSData *photo = [[FDXMPPTool sharedFDXMPPTool].xmppvCardAvatar photoDataForJID:msageObj.bareJid];
        if (photo) {
            otherCell.userImageView.image = [UIImage imageWithData:photo];
        }else{
            otherCell.userImageView.image = [UIImage imageNamed:@"瓦力"];
        }
        
        NSDateFormatter *dateformater = [NSDateFormatter new];
        dateformater.dateFormat = @"MM-DD-YY hh:mm-ss";
        //显示时间
        otherCell.timeTextLabel.text = [dateformater stringFromDate: msageObj.timestamp];
        NSRange range = [msageObj.bareJidStr rangeOfString:@"@"];
        //显示用户名
        otherCell.userNameLabel.text = [msageObj.bareJidStr substringToIndex:range.location];
        return otherCell;
    }
}




//结果集
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
      [self.msgLabel becomeFirstResponder];
     [self scrollerTOTableViewLastRow];//表格向上移动
}




//选择发送的照片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *newImage = [self thumbaiWithImage:image size:CGSizeMake(100, 100)];
    NSData *sendData = UIImageJPEGRepresentation(newImage ,0.2);
    [self sendImageMsg:sendData];
    NSLog(@"%ld",sendData.length);
    NSLog(@"%ld M ",UIImagePNGRepresentation(newImage).length);
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
//把二进制变成base64 格式
- (void )sendImageMsg:(NSData *)data{
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:[NSString stringWithFormat:@"image:%@",base64Str]];
    [[FDXMPPTool sharedFDXMPPTool].xmppStream sendElement:msg];
    
}
- (IBAction)friendInfoBtnClick:(id)sender {
    
    FDFriendInfoViewController *vc = [FDFriendInfoViewController new];
    vc.friendJid = self.friendJid;
    
    
    
} 

- (IBAction)iamgeBtnClick:(id)sender {
    UIImagePickerController *pick = [UIImagePickerController new];
    pick.delegate = self;
    pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pick.editing = YES;
    [self presentViewController:pick animated:YES completion:nil];
    
}
@end
