//
//  MFSettingsContainerViewController.h
//  botmusic
//
//  Created by Panda Systems on 9/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MFSettingsContainerViewController : UIViewController
@property (nonatomic,weak) MFSideMenuContainerViewController *container;
-(IBAction)didTapMenuButton:(id)sender;
@end
