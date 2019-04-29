//
//  ViewController.h
//  botmusic
//
//  Created by Илья Романеня on 02.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "MenuCreator.h"
#import "MusicLibary.h"
#import "DataConverter.h"

typedef NS_ENUM(NSUInteger, MFEmailViewState) {
    MFEmailViewStateSignIn,
    MFEmailViewStateSignUp,
    MFEmailViewStateForgotPassword,
};
@interface LoginViewController : UIViewController

@property(nonatomic) BOOL shownInAnonymousMode;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UILabel *logo;

//initialView
@property (weak, nonatomic) IBOutlet UIView *initalView;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UIButton* facebookButton;
@property (nonatomic, weak) IBOutlet UIButton* twitterButton;
@property (nonatomic, weak) IBOutlet UIButton* privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
- (IBAction)fb:(UIButton*)sender;

- (IBAction)emailButtonTapped:(id)sender;
- (IBAction)skipButtonTapped:(id)sender;

//email view
@property (weak, nonatomic) IBOutlet UIView *emailView;
- (IBAction)xButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUnViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
- (IBAction)rightButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
- (IBAction)leftButtonTapped:(id)sender;

//sign in view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *signInEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *signInPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *SIseparator2;
@property (weak, nonatomic) IBOutlet UIView *SIseparator3;
- (IBAction)signInButtonTapped:(id)sender;

//sign up view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *signUpNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *signUpEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *signUpPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *SUseparator1;
@property (weak, nonatomic) IBOutlet UIView *SUseparator2;
@property (weak, nonatomic) IBOutlet UIView *SUseparator3;
- (IBAction)signUpButtonTapped:(id)sender;

//forgot view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *FSeparator;
@property (weak, nonatomic) IBOutlet UITextField *forgotEmailField;
- (IBAction)sendButtonTapped:(id)sender;


@end
