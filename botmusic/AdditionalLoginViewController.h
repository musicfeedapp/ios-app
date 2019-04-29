//
//  AdditionalLoginViewController.h
//  botmusic
//
//  Created by Илья Романеня on 14.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdditionalLoginViewControllerDelegate <NSObject>

- (void)loginSuccess;
- (void)loginFailed:(NSString*)errorMessage;

@end

@interface AdditionalLoginViewController : UIViewController <AdditionalLoginViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField* loginTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (nonatomic, weak) IBOutlet UIButton* backButton;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* loginActivityIndicator;

- (IBAction)login:(id)sender;
- (IBAction)back:(id)sender;
@end
