//
//  FDSportRecordCell.h
//  Runer
//
//  Created by tarena on 16/5/20.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDSportRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *sportImageView;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordTime;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDistance;
@property (weak, nonatomic) IBOutlet UILabel *soprtRecordHot;

@end
