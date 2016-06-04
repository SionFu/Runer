//
//  FDWeiBoViewController.m
//  Runer
//
//  Created by tarena on 16/5/11.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDWeiBoViewController.h"
#import "AFNetworking.h"
#import "FDUserInfo.h"
#import "FDXMPPTool.h"
#import "NSString+md5.h"
@interface FDWeiBoViewController ()<UIWebViewDelegate,FDSRegisterDelegate,FDLoginDelegate>
- (IBAction)backBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
#define APPKEY @"2871162928"
#define APPSCRET @"48251a10a8ec697289ed23faf7e0626c"
#define REDIRECTURL @"http://www.tedu.cn"
@implementation FDWeiBoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    
    //加载官方的授权页面,让用户授权登录
    
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECTURL];
    NSURL *loadURl = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:loadURl]];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"%@",request.URL);
    NSString *url = request.URL.absoluteString;
    NSRange range = [url rangeOfString:@"?code="];
    if (range.length  > 0 ) {
        NSString *code = [url substringFromIndex:range.location + range.length];
        NSLog(@"%@",code);
        [self accessTokenWithCode:code];
        return YES;
    }
    return YES;
}
- (void)accessTokenWithCode:(NSString *)code{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    /**
     *  准备5个参数
     *
    */
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"client_id"] = APPKEY;
    parameter[@"client_secret"] = APPKEY;
    parameter[@"grant_type"] = @"authorization_code";
    parameter[@"code"] = code;
    parameter[@"redirect_uri"] = REDIRECTURL;
    
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    
    [manger POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [FDUserInfo sharedFDUserInfo].userRegister = YES;
        [FDUserInfo sharedFDUserInfo].userRegisterName = responseObject[@"uid"];
        [FDUserInfo sharedFDUserInfo].userRegisterPassword = responseObject[@"access_token"];
        [[FDXMPPTool sharedFDXMPPTool] userRegist];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [FDUserInfo sharedFDUserInfo].sinaLogin = YES;
    [self login];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- FDRegisterDelegate


- (void)registerSuccess{
    //发送web注册的请求
    [self webRegisterForServer];
     [FDXMPPTool sharedFDXMPPTool].registerDelegate = self;
    
}
- (void)login{
    //尝试自动登录 应为已经可能注册过了
    // 尝试自动登录 因为可能已经注册过
    [FDUserInfo sharedFDUserInfo].userRegister = NO;
    [FDUserInfo sharedFDUserInfo].userName = [FDUserInfo sharedFDUserInfo].userRegisterName;
    [FDUserInfo sharedFDUserInfo].userpassword = [FDUserInfo sharedFDUserInfo].userRegisterPassword;
    [FDXMPPTool sharedFDXMPPTool].loginDelegate = self;
    [[FDXMPPTool sharedFDXMPPTool]userLogin];
     [self loginSuccess];
}
- (void)registerFaild{
    [self login];
    }
- (void)registerNetError{
    
}

#pragma mark -- web Register
- (void)webRegisterForServer{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    
    //准备参数
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"username"] = [FDUserInfo sharedFDUserInfo].userRegisterName;
    #warning 完成 md5 加密
    parmaters[@"md5password"] = [[FDUserInfo sharedFDUserInfo].userRegisterPassword md5Str1];
    
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
        NSLog(@"weibo 授权成功:%@",responseObject);
        //web注册成功 应该自动登录
        [self login];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //请求失败
        NSLog(@"%@",error.userInfo);
    }];
}
#pragma mark -- LoginDelegate
-(void)loginSuccess{
    // 切换到主界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginFaild{
    
}
- (void)loginNetError{
    
}
@end
