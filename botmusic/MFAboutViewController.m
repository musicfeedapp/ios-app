//
//  MFAboutViewController.m
//  botmusic
//

#import "MFAboutViewController.h"

static NSString *const kFeedbackEmail=@"feedback@musicfeed.co";

@interface MFAboutViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation MFAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
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
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendFeedbackButtonTapped:(id)sender {
    [self openSendReview];
}

- (IBAction)termsButtonTapped:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MFTermsViewController"] animated:YES];
}

- (void)openSendReview
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
        mailController.mailComposeDelegate = self;
        
        [mailController setSubject:NSLocalizedString(@"Musicfeed feedback",nil)];
        [mailController setToRecipients:[NSArray arrayWithObject:kFeedbackEmail]];
        
        [self presentViewController:mailController animated:YES completion:nil];
        
    }
    else
    {
        NSURL* url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"mailto:%@", kFeedbackEmail]];
        [[UIApplication sharedApplication] openURL: url];
        //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Cannot send email",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        //        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
