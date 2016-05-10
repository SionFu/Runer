//
//  FDXMPPTool.m
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDXMPPTool.h"
#import "FDUserInfo.h"
@interface FDXMPPTool ()<XMPPStreamDelegate>

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
@end
@implementation FDXMPPTool

/**
 *  准备一些数据 设置流
 */
- (void)setupXmppStream{
    self.xmppStream = [XMPPStream new];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
/**
 *  连接服务器
 */
- (void) connectToServer{
    if (self.xmppStream == nil) {
        [self setupXmppStream];
    }
    self.xmppStream.hostName = FDXMPPPHOSTNAME;
    self.xmppStream.hostPort = FDXMPPPORT;
    //构建一个jid
    NSString *userName = [FDUserInfo sharedFDUserInfo].userName;
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
 *  发送密码
 */
- (void) sendPassword{
    NSString *userPassword = nil;
    NSError *error = nil;
    userPassword = [FDUserInfo sharedFDUserInfo].userpassword;
    //使用密码进进行授权
    [self.xmppStream authenticateWithPassword:userPassword error:&error];
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
}
/**
 *  发送在线消息
 */
- (void) sendOnline{
    //这个对象代表在线
    XMPPPresence *resence = [XMPPPresence presence];
    //发送在线消息
    [self.xmppStream sendElement:resence];
}
#pragma mark XMPPStreamDelegate
//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    //发送密码进行授权
    [self sendPassword];
}
//连接失败


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    if (error) {
        NSLog(@"与服务器断开连接%@",error.userInfo);
    }
}


//授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"授权成功");
}
//授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"授权失败%@",error);
}






singleton_implementation(FDXMPPTool)
@end
