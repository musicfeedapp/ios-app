//
//  MFEditPlaylistViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/20/16.
//
//

#import <UIKit/UIKit.h>

@class MFEditPlaylistViewController;

@protocol MFEditPlaylistViewControllerDelegate <NSObject>

- (void) editPlaylistController:(MFEditPlaylistViewController*)controller didFinishedWithName:(NSString*)name private:(BOOL)isPrivate;
- (void) editPlaylistControllerDidCancel:(MFEditPlaylistViewController*)controller;
- (void) editPlaylistControllerDidDelete:(MFEditPlaylistViewController*)controller;

@end

@interface MFEditPlaylistViewController : UIViewController
@property (nonatomic, strong) MFPlaylistItem* playlist;
@property (nonatomic, weak) id<MFEditPlaylistViewControllerDelegate> delegate;
@end
