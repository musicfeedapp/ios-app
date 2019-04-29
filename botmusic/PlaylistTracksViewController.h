//
//  PlaylistTracksViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import "AbstractViewController.h"
#import "MFScrollingChildDelegate.h"

@class MFPlaylistItem;

@interface PlaylistTracksViewController : AbstractViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UITableView *tracksTableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UILabel *playlistNameLabel;
@property (nonatomic, weak) id<MFScrollingChildDelegate> scrollDelegate;
@property (nonatomic, strong) UIImage* headerImage;
@property (nonatomic, strong) MFPlaylistItem *playlist;
@property (nonatomic) BOOL isUpNextPlaylist;
@property (nonatomic) BOOL isHistoryPlaylist;

@property (nonatomic, assign) BOOL isDefaultPlaylist;
@property (nonatomic, assign) BOOL isMyMusic;
@property (nonatomic) float topTableInset;
@property (nonatomic) BOOL shouldShowOwnerAvatar;
@property (nonatomic, strong) NSString *userExtId;
- (void)showTracks;
- (IBAction)didTouchUpBackButton:(id)sender;
- (IBAction)didTouchUpCloseButton:(id)sender;

@end
