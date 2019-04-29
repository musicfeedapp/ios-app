//
//  MFTermsViewController.m
//  botmusic
//
//  Created by Panda Systems on 9/8/15.
//
//

#import "MFTermsViewController.h"

@interface MFTermsViewController ()

@end

@implementation MFTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
