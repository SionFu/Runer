//
//  FDSportRecord.h
//  Runer
//
//  Created by tarena on 16/5/20.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDSportRecord : NSObject
/**
 *  用户名
 */
@property (nonatomic, strong) NSString *username;
/**
 *  运动模式
 */
@property (nonatomic, assign) enum FDSportModel sportType;
/**
 *  运动总时间
 */
@property (nonatomic, strong) NSString *sportTimeLen;
/**
 *  运动开始时间
 */
@property (nonatomic, strong) NSString *sportStartTime;
/**
 *  运动总距离
 */
@property (nonatomic, strong) NSString *sportDistance;
/**
 *  运动总热量
 */
@property (nonatomic, strong) NSString *sportHeat;
@end
