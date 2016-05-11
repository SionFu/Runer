//
//  NSString+md5.m
//  Runer
//
//  Created by tarena on 16/5/11.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (md5)
- (NSString *) md5Str{
    //1char = 1byte  = 8bits = 2个十六进制
    //因为4bit 正好可以表达一个16进制数
    // 0000 1
    // 0001 1
    const char* myPassword = [self UTF8String];
    unsigned char md5c[16];
    CC_MD5(myPassword, (CC_LONG)strlen(myPassword), md5c);
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [md5Str appendFormat:@"%02x",md5c[i]];
    }
    return md5Str;
}

- (NSString *) md5Str1{
    //1char = 1byte  = 8bits = 2个十六进制
    //因为4bit 正好可以表达一个16进制数
    // 0000 1
    // 0001 1
    const char* myPassword = [self UTF8String];
    unsigned char md5c[16];
    CC_MD5(myPassword, (CC_LONG)strlen(myPassword), md5c);
    NSMutableString *md5Str = [NSMutableString string];
    [md5Str appendFormat:@"%02x",md5c[0]];
    for (int i = 0; i < 16; i++) {
        [md5Str appendFormat:@"%02x",md5c[i]^md5c[0]];
    }
    return md5Str;
}
@end
