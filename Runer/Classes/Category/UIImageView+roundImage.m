//
//  UIImageView+roundImage.m
//  Runer
//
//  Created by tarena on 16/5/17.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "UIImageView+roundImage.h"

@implementation UIImageView (roundImage)
- (void)setRoundlay{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width *0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}
@end
