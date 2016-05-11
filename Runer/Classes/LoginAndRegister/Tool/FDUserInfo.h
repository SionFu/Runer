//
//  FDUserInfo.h
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface FDUserInfo : NSObject
singleton_interface(FDUserInfo)
/**
 * 用户名
 */
@property (nonatomic,strong) NSString *userName;
/**
 * 用户密码
 */
@property (nonatomic,strong) NSString *userpassword;

/**
 * 注册的用户名
 */
@property (nonatomic,strong) NSString *userRegisterName;
/**
 * 注册的密码
 */
@property (nonatomic,strong) NSString *userRegisterPassword;

/**
 *  用来区分登录还是注册
 */
@property (nonatomic, assign, getter=isUserRegister) BOOL *userRegister;
@end
