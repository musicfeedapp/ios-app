//
//  MFAddPlaylistViewController.m
//  botmusic
//

#import "MFAddPlaylistViewController.h"

@interface MFAddPlaylistViewController () <UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *privacyTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) BOOL isPrivate;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@end

@implementation MFAddPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.separator1Height.constant = 1.0/[UIScreen mainScreen].scale;
    self.separator2Height.constant = 1.0/[UIScreen mainScreen].scale;
    self.addTitleTextField.text = self.prefilledText;
    [self.addTitleTextField becomeFirstResponder];
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    [self validate];
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

- (IBAction)cancelButtonPressed:(id)sender {
    [self.addTitleTextField resignFirstResponder];
    [self.delegate addPlaylistControllerDidCancel:self];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.addTitleTextField resignFirstResponder];
    [self.delegate addPlaylistController:self didFinishedWithName:self.addTitleTextField.text private:_isPrivate];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}

- (void)validate{
    if(self.addTitleTextField.text.length){
        self.createButton.enabled = YES;
    } else {
        self.createButton.enabled = NO;
    }
}
- (IBAction)textFieldEditingChanged:(id)sender {
    [self validate];
}
@end
