//
//  OtherLoginViewController.m
//  botmusic
//
//  Created by Supervisor on 05.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "OtherLoginViewController.h"

@interface OtherLoginViewController ()

@end

@implementation OtherLoginViewController

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
    
    [self underlineLabel];
    
    [self prepareForView];
}
-(void)prepareForView
{
    if(IS_IPHONE_5==NO)
    {
        CGRect frame=_otherButton.frame;
        
        frame.origin.y=266;
        
        _otherButton.frame=frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)underlineLabel
{
    NSString *labelString=NSLocalizedString(@"Not now,Thanks", nil);
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    _NoThankLabel.attributedText=[[NSAttributedString alloc]initWithString:labelString attributes:underlineAttribute];
}
-(IBAction)didTapNoThanks:(id)sender
{
    
}

@end
