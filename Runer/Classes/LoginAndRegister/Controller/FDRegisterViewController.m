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
#import "AFNetworking.h"
#import "NSString+md5.h"
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
#pragma mark -- KRRegisterDelegate
- (void)registerNetError{
    [MBProgressHUD showError:@"网络错误"];
    NSLog(@"网络错误");
}
- (void)registerSuccess{
    
    
    NSLog(@"来自代理注册成功");
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"欢迎%@!",self.userNameField.text]];
    
    [self webRegisterForServer];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)registerFaild{
    NSLog(@"注册失败");
}
#pragma mark -- 按钮事件
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
    #warning 完成 md5 加密
    user.userRegisterPassword = [self.userPasswordField.text md5Str1];
    user.userRegister = YES;
    //用xmpp巩固的注册方法
    [[FDXMPPTool sharedFDXMPPTool]userRegist];
    
    //把自己设置为代理
    [FDXMPPTool sharedFDXMPPTool].registerDelegate = self;
}
#pragma mark -- web Register
- (void)webRegisterForServer{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    
    //准备参数
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"username"] = [FDUserInfo sharedFDUserInfo].userRegisterName;

    parmaters[@"md5password"] = [FDUserInfo sharedFDUserInfo].userRegisterPassword;
    
    parmaters[@"nickname"] = [FDUserInfo sharedFDUserInfo].userRegisterName;
    //赋值一个性别 1 是男 0 是女
    parmaters[@"gender"] = @1;
    //准备头像数据
    UIImage *image = [UIImage imageNamed:@"瓦力"];
    NSData *headData = UIImagePNGRepresentation(image);
    //头像参数
    [manger POST:WEBREGISTER_URL parameters:parmaters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //上传文件
        /**
         *  参数一: 上传文件的二进制数据
         *  参数二: 服务器要求的参数名 一般为: pic
         *  参数三: 在服务上要求保存的参数名
         *  参数四: 说明数据是图片类型
         */
        [formData appendPartWithFileData:headData name:@"pic" fileName:@"headImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //请求成功
        NSLog(@"%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //请求失败
        NSLog(@"%@",error.userInfo);
        
    }];
}






















@end
