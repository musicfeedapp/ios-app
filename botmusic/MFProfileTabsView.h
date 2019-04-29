//
//  MFProfileTabsView.h
//  botmusic
//
//  Created by Dzmitry Navak on 08/02/15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MFProfileTabsItem) {
    MFProfileTabsItemPlaylist,
    MFProfileTabsItemLoved,
    MFProfileTabsItemPosts,
};

@protocol MFProfileTabsViewDelegate <NSObject>

@required
- (void)onPlaylistsButtonTap;
- (void)onLovedButtonTap;
- (void)onPostsButtonTap;

@end

@interface MFProfileTabsView : UIView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* separatorHeight;
@property (nonatomic, weak) id<MFProfileTabsViewDelegate>delegate;

- (void)setCountForFollowing:(NSUInteger)following
                andFollowers:(NSUInteger)followers;

- (void)setSelectedItem:(MFProfileTabsItem)item;

- (void)setIsMyProfile:(BOOL)isMyProfile;

- (void)setShowTracks:(BOOL)isShowTracks withCount:(NSUInteger)count;

@end
