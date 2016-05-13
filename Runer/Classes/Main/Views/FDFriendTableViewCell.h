//
//  FDFriendTableViewCell.h
//  Runer
//
//  Created by tarena on 16/5/13.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDFriendTableViewCell : UITableViewCell
/**
 *  好友头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *friendHeadiamgeView;
/**
 *  好友的名字
 */
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
/**
 *  好友的状态
 */
@property (weak, nonatomic) IBOutlet UILabel *friendsStatusLabel;

@end
