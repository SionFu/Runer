//
//  FDViewController.m
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDViewController.h"
#import "FDUserInfo.h"
@interface FDViewController ()
/**
 *  用户名字段
 */
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
/**
 *  用户密码字段
 */
@property (weak, nonatomic) IBOutlet UITextField *userPasswordField;
/**
 *  登录按钮被点击
 */
- (IBAction)loginBtnClick:(id)sender;
@end

@implementation FDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加输入框左边的额ico
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
- (IBAction)loginBtnClick:(id)sender {
    /**
     *  把界面深的数据存入单例对象
     */
    [FDUserInfo sharedFDUserInfo].userName = self.userNameField.text;
    [FDUserInfo sharedFDUserInfo].userpassword = self.userPasswordField.text;
}
@end
