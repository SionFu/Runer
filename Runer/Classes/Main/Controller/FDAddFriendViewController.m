//
//  FDAddFriendViewController.m
//  Runer
//
//  Created by tarena on 16/5/13.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDAddFriendViewController.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "MBProgressHUD+KR.h"
@interface FDAddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *friendTextField;

- (IBAction)addFriendBtnClick:(id)sender;
- (IBAction)backBtnClick:(id)sender;

@end

@implementation FDAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}


- (IBAction)addFriendBtnClick:(id)sender {
    NSString *friendNage = self.friendTextField.text;
    //不能添加自己
    if ([friendNage isEqualToString:[FDUserInfo sharedFDUserInfo].userName]) {
        [MBProgressHUD showError:@"不能添加自己"];
        return;
    }
    //服务器内取得已有的好友
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",friendNage,FDXMPPDOMAIN];
    if ([[FDXMPPTool sharedFDXMPPTool].xmppRosterStore userExistsWithJID:[XMPPJID jidWithString:jidStr] xmppStream:[FDXMPPTool sharedFDXMPPTool].xmppStream]) {
        [MBProgressHUD showError:@"已经添加过好友"];
        return;
    }
    if (friendNage.length == 0) {
        [MBProgressHUD showError:@"请输入要添加的好友名"];
        return;
    }
    //添加好友
    [[FDXMPPTool sharedFDXMPPTool].xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:jidStr]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popoverPresentationController];
}

@end
