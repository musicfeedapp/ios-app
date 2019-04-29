//
//  MFAddPlaylistViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>
@class MFAddPlaylistViewController;

@protocol MFAddPlaylistViewControllerDelegate <NSObject>

- (void) addPlaylistController:(MFAddPlaylistViewController*)controller didFinishedWithName:(NSString*)name private:(BOOL)isPrivate;
- (void) addPlaylistControllerDidCancel:(MFAddPlaylistViewController*)controller;
@end

@interface MFAddPlaylistViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *addTitleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separator1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separator2Height;
@property (weak, nonatomic) id<MFAddPlaylistViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString* prefilledText;
@end
