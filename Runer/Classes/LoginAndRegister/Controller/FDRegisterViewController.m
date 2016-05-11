//
//  FDRegisterViewController.m
//  Runer
//
//  Created by tarena on 16/5/11.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDRegisterViewController.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "MBProgressHUD+KR.h"
@interface FDRegisterViewController ()<FDSRegisterDelegate>
- (IBAction)backClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordField;
- (IBAction)registerBtnClick:(id)sender;

@end

@implementation FDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加输入框左边的的ico
    [self addUserIcon];
    
    
}

#pragma mark -- 界面视图相关
- (void)addUserIcon{
    UIImageView *leftVN = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    leftVN.frame = CGRectMake(0, 0, 55, 20);
    leftVN.contentMode = UIViewContentModeCenter;
    self.userNameField.leftView = leftVN;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIImageView *leftVP = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lock"]];
    leftVP.frame = CGRectMake(0, 0, 55, 20);
    leftVP.contentMode = UIViewContentModeCenter;
    self.userPasswordField.leftView = leftVP;
    self.userPasswordField.leftViewMode = UITextFieldViewModeAlways;
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
- (void)registerNetError{
    [MBProgressHUD showError:@"网络错误"];
    NSLog(@"网络错误");
}
- (void)registerSuccess{
    NSLog(@"来自代理注册成功");
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"欢迎%@!",self.userNameField.text]];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)registerFaild{
    NSLog(@"注册失败");
}
- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)registerBtnClick:(id)sender {
    
    if (self.userNameField.text.length == 0 || self.userPasswordField.text.length == 0) {
        //提示
        [MBProgressHUD showError:@"用户名密码不能为空"];
        
    }
    FDUserInfo *user = [FDUserInfo sharedFDUserInfo];
    user.userRegisterName = self.userNameField.text;
    user.userRegisterPassword = self.userPasswordField.text;
    user.userRegister = YES;
    //用xmpp巩固的注册方法
    [[FDXMPPTool sharedFDXMPPTool]userRegist];
    
    //把自己设置为代理
    [FDXMPPTool sharedFDXMPPTool].registerDelegate = self;
}
@end
