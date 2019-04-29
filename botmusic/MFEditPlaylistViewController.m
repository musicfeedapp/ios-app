//
//  MFEditPlaylistViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/20/16.
//
//

#import "MFEditPlaylistViewController.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface MFEditPlaylistViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *playlistImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) BOOL isPrivate;
@property (weak, nonatomic) IBOutlet UITextField *privacyTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation MFEditPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleTextField.text = self.playlist.title;
    if (self.playlist.isPrivate) {
        [self.pickerView selectRow:1 inComponent:0 animated:NO];
        _isPrivate = YES;
        _privacyTextField.text = NSLocalizedString(@"Me only", nil);
    } else {
        _isPrivate = NO;
        _privacyTextField.text = NSLocalizedString(@"Everyone", nil);
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
    [self.playlistImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:self.playlist.playlistArtwork]];
    [self validate];

    // Do any additional setup after loading the view from its nib.
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
- (IBAction)doneTapped:(id)sender {
    [self.delegate editPlaylistController:self didFinishedWithName:self.titleTextField.text private:_isPrivate];
}

- (IBAction)cancelTapped:(id)sender {
    [self.delegate editPlaylistControllerDidCancel:self];
}

- (IBAction)deleteTapped:(id)sender {
    [self.delegate editPlaylistControllerDidDelete:self];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row == 0) {
        return NSLocalizedString(@"Everyone", nil);
    } else {
        return NSLocalizedString(@"Me only", nil);
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row == 0) {
        _isPrivate = NO;
        _privacyTextField.text = NSLocalizedString(@"Everyone", nil);
    } else {
        _isPrivate = YES;
        _privacyTextField.text = NSLocalizedString(@"Me only", nil);
    }
}
- (IBAction)rootViewTapped:(id)sender {
    [self.titleTextField resignFirstResponder];
}

- (void) validate{
    if (self.titleTextField.text.length) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}
- (IBAction)titleEditingChanged:(id)sender {
    [self validate];
}
@end
