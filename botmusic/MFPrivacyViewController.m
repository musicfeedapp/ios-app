//
//  MFPrivacyViewController.m
//  botmusic
//
//  Created by Panda Systems on 9/9/15.
//
//

#import "MFPrivacyViewController.h"

@interface MFPrivacyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *everyoneMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicfeedMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *meMakkLabel;
@property MFPlaylistsPrivacySettings privacy;
@end

@implementation MFPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.privacy = MFPlaylistsPrivacySettingsUsers;
    [self applyPrivacy];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) applyPrivacy{
    self.everyoneMarkLabel.hidden = !(self.privacy == MFPlaylistsPrivacySettingsEveryone);
    self.musicfeedMarkLabel.hidden = !(self.privacy == MFPlaylistsPrivacySettingsUsers);
    self.meMakkLabel.hidden = !(self.privacy == MFPlaylistsPrivacySettingsMeOnly);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)everyoneTapped:(id)sender {
    self.privacy = MFPlaylistsPrivacySettingsEveryone;
    [self applyPrivacy];
}

- (IBAction)musicfeedTapped:(id)sender {
    self.privacy = MFPlaylistsPrivacySettingsUsers;
    [self applyPrivacy];
}

- (IBAction)meOnlyTapped:(id)sender {
    self.privacy = MFPlaylistsPrivacySettingsMeOnly;
    [self applyPrivacy];
}

@end
