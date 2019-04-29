//
//  PlaylistsViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import <UIKit/UIKit.h>
#import "MFScrollingChildDelegate.h"
#import "TrackInfoViewController.h"

@class MFPlaylistItem;
@class PlaylistsViewController;

@protocol PLaylistsViewControllerDelegate <NSObject>

- (void)didSelectPlaylist:(MFPlaylistItem *)playlist isDefault:(BOOL)isDefault;
- (void)shouldShowTrackInfo:(MFTrackItem *)track;
- (void)shouldShowComments:(MFTrackItem *)track;
- (void)shouldPlayTrack:(MFTrackItem *)track;
@end

@protocol PlaylistViewControllerTrackAdditionDelegate <NSObject>

- (void)didAddTrack:(MFTrackItem *)trackItem toPlaylist:(MFPlaylistItem *)playlist;
- (void)playlistsViewController:(PlaylistsViewController*)playlistsViewController didFinishWithResult:(BOOL)trackAdded;

@end

@interface PlaylistsViewController : AbstractViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<PLaylistsViewControllerDelegate> delegate;
@property (nonatomic, weak) id<PlaylistViewControllerTrackAdditionDelegate> additionDelegate;
@property (nonatomic, weak) id<MFScrollingChildDelegate> scrollDelegate;

@property (nonatomic, weak) IBOutlet UITableView *playlistsTableView;
@property (nonatomic, weak) IBOutlet UIView *createPlaylistView;
@property (nonatomic, weak) IBOutlet UIButton *cancelPlaylistAddingButton;
@property (nonatomic, weak) IBOutlet UIButton *addPlaylistButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UITextField *playlistTextField;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (nonatomic, weak) MFPlaylistItem* playlistToRemove;
@property (nonatomic, strong) MFTrackItem *trackToAdd;
@property (nonatomic, strong) MFUserInfo *userInfo;
@property (nonatomic) float topTableInset;

- (IBAction)didTouchUpAddPlaylistButton:(id)sender;
- (IBAction)didTouchUpCancelAddingPlaylistButton:(id)sender;
- (IBAction)didTouchUpBackButton:(id)sender;

- (IBAction)didTextFieldSelectDone:(id)sender;
- (void)downloadPlaylists;
@end
