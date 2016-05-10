//
//  FDXMPPTool.m
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDXMPPTool.h"
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

@end
