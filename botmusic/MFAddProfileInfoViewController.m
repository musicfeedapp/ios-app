//
//  MFAddProfileInfoViewController.m
//  botmusic
//

#import "MFAddProfileInfoViewController.h"

@interface MFAddProfileInfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@property(nonatomic, copy) MFAddInfoCompletionBlock completionBlock;

@end

@implementation MFAddProfileInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionLabel.text = self.headerTitle;
    self.infoTextField.placeholder = self.textFieldPlaceholder;
    // Do any additional setup after loading the view from its nib.
    if (self.infoToEdit) {
        self.infoTextField.text = self.infoToEdit;
    }
    if (self.infoTextField.text.length) {
        self.updateButton.enabled = YES;
    } else {
        self.updateButton.enabled = NO;
    }
    [self.infoTextField becomeFirstResponder];
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
- (IBAction)textFieldEditingChanged:(UITextField*)sender {
    if (sender.text.length) {
        self.updateButton.enabled = YES;
    } else {
        self.updateButton.enabled = NO;
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self.infoTextField resignFirstResponder];
    self.completionBlock(NO, nil);
    self.completionBlock = nil;
}

- (IBAction)updateTapped:(id)sender {
    [self.infoTextField resignFirstResponder];
    self.completionBlock(YES, self.infoTextField.text);
    self.completionBlock = nil;
}

@end
