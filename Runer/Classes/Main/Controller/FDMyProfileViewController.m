//
//  FDMyProfileViewController.m
//  Runer
//
//  Created by tarena on 16/5/12.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDMyProfileViewController.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"
#import "XMPPvCardTemp.h"
@interface FDMyProfileViewController ()
- (IBAction)backBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNiceName;

@end

@implementation FDMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

//每次到这个界面会更新信息
- (void)viewWillAppear:(BOOL)animated{
     //获取个人信息
    XMPPvCardTemp *vCardTemp = [FDXMPPTool sharedFDXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.headImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"瓦力"];
    }
    self.userNiceName.text = [NSString stringWithFormat:@"昵称:%@",vCardTemp.nickname];
    self.userNameLabel.text = [NSString stringWithFormat:@"用户名:%@",[FDUserInfo sharedFDUserInfo].userName];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
