//
//  FDEditMyprofileViewController.m
//  Runer
//
//  Created by tarena on 16/5/12.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDEditMyprofileViewController.h"
#import "XMPPvCardTemp.h"
#import "FDXMPPTool.h"
#import "FDUserInfo.h"

@interface FDEditMyprofileViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
- (IBAction)backBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UITextField *userNickNameField;
@property (weak, nonatomic) IBOutlet UITextField *userEmailField;
- (IBAction)updateMyprofileBtnClick:(id)sender;

@end

@implementation FDEditMyprofileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取个人信息
    XMPPvCardTemp *vCardTemp = [FDXMPPTool sharedFDXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.headImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"瓦力"];
    }
    self.userNickNameField.text = vCardTemp.nickname;
    self.userEmailField.text = vCardTemp.mailer;
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageViewTep)]];
    
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
- (IBAction)updateMyprofileBtnClick:(id)sender {
    // 获取个人信息模型对象
    XMPPvCardTemp *myProfile = [FDXMPPTool sharedFDXMPPTool].xmppvCard.myvCardTemp;
    myProfile.nickname = self.userNickNameField.text;
    myProfile.mailer = self.userEmailField.text;
    //头像数据
    
    myProfile.photo = UIImagePNGRepresentation(self.headImageView.image);
//    myProfile.photo = UIImagePNGRepresentation([UIImage imageNamed:@"人人"]);

    
    //使用工具类更新个人信息
    [[FDXMPPTool sharedFDXMPPTool].xmppvCard updateMyvCardTemp:myProfile];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)headImageViewTep{
//    [self choolImage:UIImagePickerControllerSourceTypePhotoLibrary];
    
//
    // 打开相册 或者相机 选取图片
    UIActionSheet *sht1 = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"相册", nil];
    [sht1 showInView:self.view];

}


-(void)choolImage:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType =type;
    picker.allowsEditing = YES;
    //设置代理
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    MYLog(@"%@",info);
    UIImage *image = info[UIImagePickerControllerEditedImage];//取原图还是编辑过的图片
    self.headImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        MYLog(@"cencel");
    }else if (buttonIndex == 1){
        MYLog(@"相册");
        UIImagePickerController *pc = [[UIImagePickerController alloc]init];
        pc.allowsEditing = YES;
        pc.delegate = self;
        pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pc animated:YES completion:nil];
    }else{
        MYLog(@"相机");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //可以打开相机
        }else{
            MYLog(@"该设备暂时不支持打开相机");
        }
    }
}




@end
