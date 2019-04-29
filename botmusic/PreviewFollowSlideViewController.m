//
//  PreviewFollowSlideViewController.m
//  botmusic
//
//  Created by Dzionis Brek on 24.02.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "PreviewFollowSlideViewController.h"
#import "UIView+Utilities.h"
#import "MFFollowItem+Behavior.h"

@interface PreviewFollowSlideViewController ()

@end

@implementation PreviewFollowSlideViewController

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
    
    [self setUsersImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set user image

-(void)setUsersImage{
    NSString *friendPicture=[(PreviewViewController*)self.parentViewController.parentViewController friendPicture];
    NSString *artistPicture=[(PreviewViewController*)self.parentViewController.parentViewController artistPicture];
    NSString *friendUsername=[(PreviewViewController*)self.parentViewController.parentViewController friendUsername];
    NSString *artistUsername=[(PreviewViewController*)self.parentViewController.parentViewController artistUsername];
    
    [self.friendImage.layer setCornerRadius:self.friendImage.frame.size.height/2];
    [self.friendImage setClipsToBounds:YES];
    [self.friendImage setImageWithURL:[NSURL URLWithString:friendPicture]];
    
    [self.artistImage.layer setCornerRadius:self.friendImage.frame.size.height/2];
    [self.artistImage setClipsToBounds:YES];
    [self.artistImage setImageWithURL:[NSURL URLWithString:artistPicture]];
    
    [self.friendUsernameLabel setText:[NSString stringWithFormat:@"@%@",friendUsername]];
    [self.artistUsernameLabel setText:[NSString stringWithFormat:@"@%@",artistUsername]];
}

@end
