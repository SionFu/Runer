//
//  FDFriendInfoViewController.m
//  Runer
//
//  Created by tarena on 16/5/16.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDFriendInfoViewController.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
@interface FDFriendInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendNickNameLabel;

@end

@implementation FDFriendInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadFiends];
}
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
   

    
    
}
- (void)viewWillAppear:(BOOL)animated{
    self.friendNameLabel.text = self.friendJid.user;
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

@end
