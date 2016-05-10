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

@protocol FDLoginDelegate <NSObject>

//登陆成功
- (void) loginSuccess;
//登陆失败
- (void) loginFaild;
//网路错误
- (void) loginNetError;

@end

/**
 *  包装XMPPFramework的工具类
 */
@interface FDXMPPTool : NSObject
singleton_interface(FDXMPPTool)
@property (nonatomic, weak) id<FDLoginDelegate> loginDelegate;
/**
 *  和服务器交互最主要的对象
 */
@property (nonatomic, strong) XMPPStream *xmppStream;

//公开一个登陆接口
- (void) userLogin;
@end
