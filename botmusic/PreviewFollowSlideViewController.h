//
//  PreviewFollowSlideViewController.h
//  botmusic
//
//  Created by Dzionis Brek on 24.02.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"

@interface PreviewFollowSlideViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *artistUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendUsernameLabel;
@end
