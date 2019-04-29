//
//  MFProfileTabsView.m
//  botmusic
//
//  Created by Dzmitry Navak on 08/02/15.
//
//

#import "MFProfileTabsView.h"

@interface MFProfileTabsView ()

@property (weak, nonatomic) IBOutlet UIButton *playlistsButton;
@property (weak, nonatomic) IBOutlet UIButton *lovedButton;
@property (weak, nonatomic) IBOutlet UIButton *postsButton;
@property (weak, nonatomic) IBOutlet UIView *playlistsUnderline;
@property (weak, nonatomic) IBOutlet UIView *lovedUnderline;
@property (weak, nonatomic) IBOutlet UIView *postsUnderline;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proportionalConstraint;
@end

@implementation MFProfileTabsView

- (void)setSelectedItem:(MFProfileTabsItem)item {
    switch (item) {
        case MFProfileTabsItemPlaylist:
            [self onPlaylistsButtonTap:nil];
            break;
            
        case MFProfileTabsItemLoved:
            [self onLovedButtonTap:nil];
            break;
            
        case MFProfileTabsItemPosts:
            [self onPostsButtonTap:nil];
            break;
    }
}

- (void)setIsMyProfile:(BOOL)isMyProfile {

}

#pragma mark - aactions

- (IBAction)onPlaylistsButtonTap:(id)sender {
    [self.delegate onPlaylistsButtonTap];
    self.playlistsButton.selected = YES;
    self.lovedButton.selected  = NO;
    self.postsButton.selected  = NO;
    
    self.playlistsUnderline.hidden = NO;
    self.lovedUnderline.hidden = YES;
    self.postsUnderline.hidden = YES;
}
- (IBAction)onLovedButtonTap:(id)sender {
    [self.delegate onLovedButtonTap];
    self.playlistsButton.selected = NO;
    self.lovedButton.selected  = YES;
    self.postsButton.selected  = NO;
    
    self.playlistsUnderline.hidden = YES;
    self.lovedUnderline.hidden = NO;
    self.postsUnderline.hidden = YES;
}
- (IBAction)onPostsButtonTap:(id)sender {
    [self.delegate onPostsButtonTap];
    self.playlistsButton.selected = NO;
    self.lovedButton.selected  = NO;
    self.postsButton.selected  = YES;
    
    self.playlistsUnderline.hidden = YES;
    self.lovedUnderline.hidden = YES;
    self.postsUnderline.hidden = NO;
}

@end
