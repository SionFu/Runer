//
//  FDXMPPTool.h
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "Singleton.h"
/**
 *  web服务器返回状况
 */
@protocol FDLoginDelegate <NSObject>

//登陆成功
- (void) loginSuccess;
//登陆失败
- (void) loginFaild;
//网路错误
- (void) loginNetError;

@end

@protocol FDSRegisterDelegate <NSObject>

//注册成功
- (void) registerSuccess;
//注册失败
- (void) registerFaild;
//网络错误
- (void) registerNetError;
@end
/**
 *  包装XMPPFramework的工具类
 */
@interface FDXMPPTool : NSObject
singleton_interface(FDXMPPTool)
@property (nonatomic, weak) id<FDLoginDelegate> loginDelegate;
@property (nonatomic, weak) id<FDSRegisterDelegate> registerDelegate;
/**
 *  和服务器交互最主要的对象
 */
@property (nonatomic, strong) XMPPStream *xmppStream;

//公开一个登陆接口
- (void) userLogin;

//公开一个注册接口
- (void) userRegist;


@end
