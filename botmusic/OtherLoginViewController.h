//
//  OtherLoginViewController.h
//  botmusic
//
//  Created by Supervisor on 05.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"

@interface OtherLoginViewController : UIViewController

@property(nonatomic)IBOutlet UILabel *NoThankLabel;
@property(nonatomic)IBOutlet UIButton *otherButton;

-(IBAction)didTapNoThanks:(id)sender;

@end
