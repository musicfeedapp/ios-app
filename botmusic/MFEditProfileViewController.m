//
//  MFEditProfileViewController.m
//  botmusic
//
//  Created by Panda Systems on 9/11/15.
//
//

#import "MFEditProfileViewController.h"
#import "MFEmailTableViewCell.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "UIColor+Expanded.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFAddProfileInfoViewController.h"

@interface MFEditProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITableView *emailsTableView;
@property (weak, nonatomic) IBOutlet UITableView *phonesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailsTableHeightContaraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phonesTableConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroungImageView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) MFUserInfo* userInfo;
@property (nonatomic, copy) NSString* primaryEmail;
@property (nonatomic, strong) NSMutableArray* secondaryEmails;
@property (nonatomic, strong) NSMutableArray* phones;
@property (nonatomic) BOOL avatarChoosen;
@property (nonatomic) BOOL emailsOrPhonesChanged;
@end

@implementation MFEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userInfo = userManager.userInfo;
    //self.userInfo = [MFUserInfo MR_findFirst];
    self.nameTextField.text = self.userInfo.name;
    self.secondaryEmails = [NSMutableArray array];
    if (self.userInfo.email.length) {
        self.primaryEmail = self.userInfo.email;
    }

    self.secondaryEmails = [self.userInfo.secondaryEmails mutableCopy];
    self.phones = [NSMutableArray array];
    if (self.userInfo.phone.length) {
        [self.phones addObject:self.userInfo.phone];
    }
    [self.phones addObjectsFromArray:self.userInfo.secondaryPhones];
    //fake data
//    self.secondaryEmails = [NSMutableArray arrayWithObjects:@"hello@hello.com", @"test@test.com", nil];
//    self.primaryEmail = @"primary@primary.com";
//    self.secondaryPhones = [NSMutableArray arrayWithObjects:@"+37599999999", @"+7467422222", nil];
//    self.primaryPhone = @"8-800-555-35-35";

    [self updateImage:self.userInfo.profileImage];
    [self adjustEmailsTableHeight];
    [self adjustPhoneTableHeight];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.emailsTableView registerNib:[UINib nibWithNibName:@"MFEmailTableViewCell" bundle:nil] forCellReuseIdentifier:@"MFEmailTableViewCell"];
    [self.phonesTableView registerNib:[UINib nibWithNibName:@"MFEmailTableViewCell" bundle:nil] forCellReuseIdentifier:@"MFEmailTableViewCell"];

    if (self.isShownFromBottom) {
        self.backButton.hidden = YES;
        self.dismissButton.hidden = NO;
    } else {
        self.backButton.hidden = NO;
        self.dismissButton.hidden = YES;
    }
}

- (void) updateImage:(NSString*)imageLink{
//    [self.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:imageLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.backgroungImageView.image = image;
//    }];
    [self.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:imageLink] name:self.userInfo.name];
    [self.backgroungImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:imageLink]];

}

- (void) deleteImage{
    [self.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:@""] name:self.userInfo.name];
    self.backgroungImageView.image = nil;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==_emailsTableView) {
        if (self.secondaryEmails.count<4) return self.secondaryEmails.count+2;
        else return self.secondaryEmails.count+1;
    } else {
        if (self.phones.count<5) return self.phones.count+1;
        else return self.phones.count;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_emailsTableView) {

        if (self.secondaryEmails.count<4 && indexPath.row == self.secondaryEmails.count+1) {
            MFEmailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFEmailTableViewCell"];
            cell.emailTextField.text = @"";
            cell.emailTextField.placeholder = @"Add Another Email...";
            UIColor *color = [UIColor colorWithRGBHex:0x007AFF];
            NSMutableAttributedString* attrString = [cell.emailTextField.attributedPlaceholder mutableCopy];
            [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
            cell.emailTextField.attributedPlaceholder = attrString;
            cell.primaryLabel.hidden = YES;
            return cell;
        }
        
        MFEmailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFEmailTableViewCell"];
        cell.emailTextField.placeholder = @"";
        if (indexPath.row == 0) {
            cell.emailTextField.text = self.primaryEmail;
            [cell.emailTextField setTag:indexPath.row];
            cell.primaryLabel.hidden = NO;
        } else if (indexPath.row<self.secondaryEmails.count+1) {
            cell.emailTextField.text = self.secondaryEmails[indexPath.row-1];
            [cell.emailTextField setTag:indexPath.row];
            cell.primaryLabel.hidden = YES;
        }
        return cell;

    } else {
        if (self.phones.count<5 && indexPath.row == self.phones.count) {
            MFEmailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFEmailTableViewCell"];
            cell.emailTextField.text = @"";
            cell.emailTextField.placeholder = @"Add Another Phone...";
            UIColor *color = [UIColor colorWithRGBHex:0x007AFF];
            NSMutableAttributedString* attrString = [cell.emailTextField.attributedPlaceholder mutableCopy];
            [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
            cell.emailTextField.attributedPlaceholder = attrString;
            cell.primaryLabel.hidden = YES;
            return cell;
        }

        MFEmailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFEmailTableViewCell"];
        cell.emailTextField.placeholder = @"";
        if (indexPath.row == 0) {
            cell.emailTextField.text = self.phones[indexPath.row];
            [cell.emailTextField setTag:indexPath.row];
            cell.primaryLabel.hidden = NO;
        } else if (indexPath.row<self.phones.count+1) {
            cell.emailTextField.text = self.phones[indexPath.row];
            [cell.emailTextField setTag:indexPath.row];
            cell.primaryLabel.hidden = YES;
        }
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_emailsTableView) {
        if (indexPath.row == 0){
            [[[UIAlertView alloc] initWithTitle:@"In order to edit or delete this email address, another primary address must be set first." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        } else if (indexPath.row == self.secondaryEmails.count+1){
            [self addNewEmail];
        } else {
            [self editEmailAtIndexPath:indexPath];
        }
    } else {
        if (indexPath.row == 0){
            if (self.phones.count) {
                [[[UIAlertView alloc] initWithTitle:@"In order to edit or delete this phone number, another primary phone number must be set first." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            } else {
                [self addNewPhone];
            }
        } else if (indexPath.row == self.phones.count){
            [self addNewPhone];
        } else {
            [self editPhoneAtIndexPath:indexPath];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)editEmailAtIndexPath:(NSIndexPath*)ip{
    MFEmailTableViewCell* cell = [_emailsTableView cellForRowAtIndexPath:ip];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:cell.emailTextField.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Make Primary" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSString* info = self.secondaryEmails[ip.row-1];
//        [self.secondaryEmails replaceObjectAtIndex:ip.row-1 withObject:self.primaryEmail];
//        self.primaryEmail = info;
//        [_emailsTableView reloadData];
//    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        MFAddProfileInfoViewController* infoVC = [[MFAddProfileInfoViewController alloc] init];
        infoVC.infoToEdit = self.secondaryEmails[ip.row-1];
        infoVC.headerTitle = @"Edit Email";
        infoVC.textFieldPlaceholder = @"Email address";
        [infoVC setCompletionBlock:^(BOOL added, NSString *info) {
            if (added) {
                [self.secondaryEmails replaceObjectAtIndex:ip.row-1 withObject:info];
                [self adjustEmailsTableHeight];
                [self.emailsTableView reloadData];
                self.emailsOrPhonesChanged = YES;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:infoVC animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.secondaryEmails removeObjectAtIndex:ip.row-1];
        [self adjustEmailsTableHeight];
        [self.emailsTableView reloadData];
        self.emailsOrPhonesChanged = YES;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)editPhoneAtIndexPath:(NSIndexPath*)ip{
    MFEmailTableViewCell* cell = [_phonesTableView cellForRowAtIndexPath:ip];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:cell.emailTextField.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Make Primary" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString* info = self.phones[ip.row];
        self.phones[ip.row] = self.phones[0];
        self.phones[0] = info;
        [_phonesTableView reloadData];
        self.emailsOrPhonesChanged = YES;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        MFAddProfileInfoViewController* infoVC = [[MFAddProfileInfoViewController alloc] init];
        infoVC.infoToEdit = self.phones[ip.row];
        infoVC.headerTitle = @"Edit Phone";
        infoVC.textFieldPlaceholder = @"Phone number";
        [infoVC setCompletionBlock:^(BOOL added, NSString *info) {
            if (added) {
                [self.phones replaceObjectAtIndex:ip.row withObject:info];
                [self adjustPhoneTableHeight];
                [self.phonesTableView reloadData];
                self.emailsOrPhonesChanged = YES;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:infoVC animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.phones removeObjectAtIndex:ip.row];
        [self adjustPhoneTableHeight];
        [self.phonesTableView reloadData];
        self.emailsOrPhonesChanged = YES;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)addNewEmail{
    MFAddProfileInfoViewController* infoVC = [[MFAddProfileInfoViewController alloc] init];
    infoVC.infoToEdit = nil;
    infoVC.headerTitle = @"Add Email";
    infoVC.textFieldPlaceholder = @"Email address";
    [infoVC setCompletionBlock:^(BOOL added, NSString *info) {
        if (added) {
            [self.secondaryEmails addObject:info];
            [self adjustEmailsTableHeight];
            [self.emailsTableView reloadData];
            self.emailsOrPhonesChanged = YES;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:infoVC animated:YES completion:nil];
}

- (void)addNewPhone{
    MFAddProfileInfoViewController* infoVC = [[MFAddProfileInfoViewController alloc] init];
    infoVC.infoToEdit = nil;
    infoVC.headerTitle = @"Add Phone";
    infoVC.textFieldPlaceholder = @"Phone number";
    [infoVC setCompletionBlock:^(BOOL added, NSString *info) {
        if (added) {
            [self.phones addObject:info];
            [self adjustPhoneTableHeight];
            [self.phonesTableView reloadData];
            self.emailsOrPhonesChanged = YES;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:infoVC animated:YES completion:nil];
}

- (IBAction)imageViewTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Update profile picture" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }]];
    if (self.userInfo.facebookLink.length) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Import from Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self removeAvatar];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhoto {

    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)selectPhoto {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.avatarImageView.image = image;
    [self.avatarImageView hideInitialsLabel];
    self.backgroungImageView.image = image;
    self.avatarChoosen = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) adjustEmailsTableHeight{
    if (self.secondaryEmails.count<4) {
        self.emailsTableHeightContaraint.constant = 40.0*(2+self.secondaryEmails.count);
    } else {
        self.emailsTableHeightContaraint.constant = 40.0*(1+self.secondaryEmails.count);
    }
}

- (void) adjustPhoneTableHeight{
    if (self.phones.count<5) {
        self.phonesTableConstraint.constant = 40.0*(1+self.phones.count);
    } else {
        self.phonesTableConstraint.constant = 40.0*(self.phones.count);
    }
}

- (IBAction)viewTapped:(id)sender {
    for (MFEmailTableViewCell* cell in [self.emailsTableView visibleCells]) {
        [cell.emailTextField resignFirstResponder];
    }
    [self.nameTextField resignFirstResponder];
}

- (IBAction)nameTextFieldDidEnd:(id)sender {
    [self.nameTextField resignFirstResponder];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self applyChanges];
}

- (void)applyChanges{
    if (!self.emailsOrPhonesChanged && [self.userInfo.name isEqualToString:self.nameTextField.text] && !self.avatarChoosen) {
        return;
    }
    NSMutableDictionary* dictionary = [@{ @"username": self.nameTextField.text, @"name": self.nameTextField.text, @"email": self.primaryEmail, @"secondary_emails": self.secondaryEmails,  @"contact_number": @"12321321" } mutableCopy];
    if (self.phones.count) {
        [dictionary setObject:self.phones[0] forKey:@"contact_number"];
        [dictionary setObject:[self.phones subarrayWithRange:NSMakeRange(1, self.phones.count-1)] forKey:@"secondary_phones"];
    }
    UIImage* avatar = nil;
    if (self.avatarChoosen) {
        avatar = self.avatarImageView.image;
        CGFloat scale = 200.0/MIN(avatar.size.width, avatar.size.height);
        CGSize newsize = CGSizeMake(avatar.size.width*scale, avatar.size.height*scale);
        avatar = [self imageWithImage:avatar scaledToSize:newsize];
    }



    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil userInfo:@{@"avatar":avatar, @"avatarInstaChanging":@(YES)}];

    [[IRNetworkClient sharedInstance] updateProfile:dictionary avatar:avatar successBlock:^(NSDictionary *dictionary) {
        if ([[dictionary objectForKey:@"profile_image"] isKindOfClass:[NSString class]]) {
            self.userInfo.profileImage = [dictionary objectForKey:@"profile_image"];
            UIImageView* dummy = [[UIImageView alloc] init];
            [dummy sd_setImageWithURL:[NSURL URLWithString:self.userInfo.profileImage]];

        }
        self.userInfo.username = [dictionary objectForKey:@"username"];
        self.userInfo.name = [dictionary objectForKey:@"name"];
        self.userInfo.email = [dictionary objectForKey:@"email"];
        self.userInfo.secondaryEmails = [dictionary objectForKey:@"secondary_emails"];
        if (self.phones.count) {
            self.userInfo.phone = self.phones[0];
            self.userInfo.secondaryPhones = [self.phones subarrayWithRange:NSMakeRange(1, self.phones.count-1)];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil userInfo:@{@"avatar":avatar}];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

        //[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }];
}

- (void)removeAvatar{
    NSMutableDictionary* dictionary = [@{ @"remove_avatar": @(YES),} mutableCopy];
    
    [[IRNetworkClient sharedInstance] updateProfile:dictionary avatar:nil successBlock:^(NSDictionary *dictionary) {
        if ([[dictionary objectForKey:@"profile_image"] isKindOfClass:[NSString class]]) {
            self.userInfo.profileImage = [dictionary objectForKey:@"profile_image"];
            [self updateImage:self.userInfo.profileImage];
            self.avatarChoosen = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }];
}


- (void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary* info = [note userInfo];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)dismissButtonTapped:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
    [self applyChanges];

}
@end
