//
//  FDUserInfo.m
//  Runer
//
//  Created by tarena on 16/5/10.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDUserInfo.h"

@implementation FDUserInfo
singleton_implementation(FDUserInfo)
-(NSString *)jidStr{
    return [NSString stringWithFormat:@"%@@%@",self.userName,FDXMPPDOMAIN];
}
@end
