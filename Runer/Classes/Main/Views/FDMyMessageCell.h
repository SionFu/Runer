//
//  FDMyMessageCell.h
//  Runer
//
//  Created by tarena on 16/5/17.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDMyMessageCell : UITableViewCell
/**
 *  头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
/**
 *  用户名
 */
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
/**
 *  消息时间
 */
@property (weak, nonatomic) IBOutlet UILabel *mssageTimeLabel;
/**
 *  消息内容
 */
@property (weak, nonatomic) IBOutlet UILabel *massageLabel;

@end
