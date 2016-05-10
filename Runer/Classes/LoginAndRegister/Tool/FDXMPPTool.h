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
 *  包装XMPPFramework的工具类
 */
@interface FDXMPPTool : NSObject
singleton_interface(FDXMPPTool)
/**
 *  和服务器交互最主要的对象
 */
@property (nonatomic, strong) XMPPStream *xmppStream;
@end
