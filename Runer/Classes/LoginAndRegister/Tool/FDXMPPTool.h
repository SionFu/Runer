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
 *  定义电子名片模块和对应的存储
 */
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCard;
@property (nonatomic,strong)  XMPPvCardCoreDataStorage *xmppvCardStore;
//增加头像模块  头像模块个电子名片模块需要一起使用
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatar;
//增加好友模块 也叫花名册模块
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStore;
/**
 *  和服务器交互最主要的对象
 */
@property (nonatomic, strong) XMPPStream *xmppStream;

//公开一个登陆接口
- (void) userLogin;

//公开一个注册接口
- (void) userRegist;


@end
