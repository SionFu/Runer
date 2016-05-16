//
//  FDMeTableViewCell.h
//  Runer
//
//  Created by tarena on 16/5/16.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDMeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNageLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end
