//
//  FDXMPPTool.m
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "AppDelegate.h"

@interface FDXMPPTool ()<XMPPStreamDelegate,XMPPRosterDelegate,UIActionSheetDelegate>

/**
 *  准备一些数据 设置流
 */
- (void)setupXmppStream;
/**
 *  连接服务器
 */
- (void) connectToServer;
/**
 *  发送密码
 */
- (void) sendPassword;
/**
 *  发送在线消息
 */
- (void) sendOnline;
/**
 *  申请添加好友的id
 */
@property (strong,nonatomic) XMPPJID *fJid;
@end
@implementation FDXMPPTool


singleton_implementation(FDXMPPTool)

/**
 *  准备一些数据 设置流
 */
- (void)setupXmppStream{
    self.xmppStream = [XMPPStream new];
    //设置代理
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //给电子名片模块和对应的存储赋值
    self.xmppvCardStore = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStore];
    self.xmppvCardAvatar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCard];
    //给花名册模块 和对应的存储赋值
    self.xmppRosterStore = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:self.xmppRosterStore];
    //设置处理好友请求 的机制
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //激活电子名片模块
    [self.xmppvCard activate:self.xmppStream];
    //激活头像模块
    [self.xmppvCardAvatar activate:self.xmppStream];
    //激活花名册模块
    [self.xmppRoster activate:self.xmppStream];
    
}
/**
 *  连接服务器
 */
- (void) connectToServer{
    //先把之前的接连断开
    [self.xmppStream disconnect];
    if (self.xmppStream == nil) {
        [self setupXmppStream];
    }
    self.xmppStream.hostName = FDXMPPPHOSTNAME;
    self.xmppStream.hostPort = FDXMPPPORT;
    NSString *userName = nil;
    if ([FDUserInfo sharedFDUserInfo].isUserRegister) {
        userName = [FDUserInfo sharedFDUserInfo].userRegisterName;
    }else{
    //构建一个jid
        userName = [FDUserInfo sharedFDUserInfo].userName;
    }
    
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,FDXMPPDOMAIN];
    
    //设置jid
    self.xmppStream.myJID = [XMPPJID jidWithString:jidStr];
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
}
/**
 *  发送密码/发送注册密码
 */
- (void) sendPassword{
    NSString *userPassword = nil;
    NSError *error = nil;
    if ([FDUserInfo sharedFDUserInfo].isUserRegister) {
      userPassword = [FDUserInfo sharedFDUserInfo].userRegisterPassword;
    [self.xmppStream registerWithPassword:userPassword error:&error];
        
    }else{
    userPassword = [FDUserInfo sharedFDUserInfo].userpassword;
    //使用密码进进行授权
    [self.xmppStream authenticateWithPassword:userPassword error:&error];
    }
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
}
/**
 *  发送在线消息
 */
- (void) sendOnline{
    //这个对象代表在线
    XMPPPresence *presence = [XMPPPresence presence];
    //发送在线消息
    [self.xmppStream sendElement:presence];
}
#pragma mark XMPPStreamDelegate

//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    [self.registerDelegate registerSuccess];
    NSLog(@"注册成功");
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    [self.registerDelegate registerFaild];
    NSLog(@"%@注册失败%@",sender,error);
}
//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
        //发送密码
        [self sendPassword];
}

//连接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    if (error) {
        [self.loginDelegate loginNetError];
        [self.registerDelegate registerNetError];
        NSLog(@"与服务器断开连接%@",error.userInfo);
    }
}

//授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [self sendOnline];
    [self.loginDelegate loginSuccess];
    NSLog(@"授权成功");
}
//授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    
    NSLog(@"授权失败%@",error);
}



- (void)userLogin{
    [self connectToServer];
}

- (void)userRegist{
    [self connectToServer];
}
//处理添加好友

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
        //请求的用户
    NSString *presenceFrom = [[presence from]user];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@好友添加请求",presenceFrom] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"同意" otherButtonTitles:@"同意并添加对方", nil];
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFrom,FDXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index====%ld",buttonIndex);
    if (0 == buttonIndex) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:NO];
    }else if(1== buttonIndex){
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:YES];
    }else{
        [self.xmppRoster  rejectPresenceSubscriptionRequestFrom:self.fJid];
    }
    
}

-(void)addFriendWith:(NSString *)friendNage{
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
}
@end
