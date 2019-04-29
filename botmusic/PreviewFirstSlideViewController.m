//
//  PreviewFirstSlideViewController.m
//  botmusic
//
//  Created by Dzionis Brek on 24.02.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "PreviewFirstSlideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache_FadeIn.h"
@interface PreviewFirstSlideViewController ()

@property(nonatomic,weak)IBOutlet UILabel *welcomeLabel;
@property(nonatomic, weak)IBOutlet UILabel *nameLabel;
@property(nonatomic, weak)IBOutlet UIImageView *avatar;

@end

@implementation PreviewFirstSlideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setProfileImage];
    
    [self setWelcomeText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Preparation methods

-(void)setProfileImage{
    self.nameLabel.text = userManager.userInfo.name;
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    self.avatar.clipsToBounds = YES;
    
    NSString *url=userManager.userInfo.profileImage;
    NSURL *avatarURL=[NSURL URLWithString:url];
	[self.avatar sd_setImageWithURL:avatarURL placeholderImage:nil];
}
-(void)setWelcomeText{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Welcome to musicfeed", nil)];
    
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:25.0] range:NSMakeRange(0, 10)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FancierScript" size:35.0f]range:NSMakeRange(10,10)];
    
    self.welcomeLabel.attributedText = str;
}
@end
