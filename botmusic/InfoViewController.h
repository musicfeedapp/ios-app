//
//  InfoViewController.h
//  botmusic
//
//  Created by Supervisor on 19.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UITextView *textView;

-(IBAction)didSelectBack:(id)sender;

@end
