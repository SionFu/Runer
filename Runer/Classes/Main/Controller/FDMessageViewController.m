//
//  FDMessageViewController.m
//  Runer
//
//  Created by tarena on 16/5/14.
//  Copyright © 2016年 Fu_sion. All rights reserved.
//

#import "FDMessageViewController.h"
@interface FDMessageViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTield;
@end

@implementation FDMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//添加监听键盘出现和收回的通知
- (void)viewWillAppear:(BOOL)animated{
      [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    self.title = self.friendJid.user;
}
//键盘弹出
- (void)showKeyboard:(NSNotification *)notification{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    CGRect rect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey]CGRectValue];
    CGFloat height = rect.size.height;
    self.buttomTextView.constant = height;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.inputTield.leftViewMode = UITextFieldViewModeAlways;
    self.inputTield.leftView = imageView;
    [UIView animateKeyframesWithDuration:duration delay:0 options:option animations:^{
        [self.view layoutIfNeeded];
//        [self scrollerTOTableViewLastRow];表格向上移动
    } completion:nil];

}
//键盘收起
- (void)closeKeyboard:(NSNotification *)notification{
    //键盘弹起的持续时间
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    //键盘弹起动画的类型
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    //将输入框view移动到初始位置
    self.buttomTextView.constant = 0;
    [UIView animateKeyframesWithDuration:duration delay:0 options:option animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
