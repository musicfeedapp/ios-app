//
//  MFFollowingViewController.h
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import <UIKit/UIKit.h>
#import "MFScrollingChildDelegate.h"

typedef enum {
    MFShowAll,
    MFShowUsers,
    MFShowArtists
} MFShowFollowingState;

@interface MFFollowingViewController : AbstractViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImage* headerImage;

@property (nonatomic) BOOL hideSortTabs;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (nonatomic, weak) IBOutlet UIButton *showUsersButton;
@property (nonatomic, weak) IBOutlet UIButton *showArtistsButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) MFUserInfo* userInfo;
@property (nonatomic) BOOL isMyFollowItems;

@property (nonatomic, strong) NSMutableArray *usersFollowItems;
@property (nonatomic, strong) NSMutableArray *artistsFollowItems;
@property (nonatomic, strong) NSMutableArray* allFollowItems;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, assign) MFShowFollowingState showFollowingState;

- (IBAction)didTouchUpUsersButton:(id)sender;
- (IBAction)didTouchUpArtistsButton:(id)sender;
- (CGFloat) headerHeight;
- (void) setHeaderHeight:(CGFloat)headerHeight;
- (IBAction)didTouchSegmentControl:(id)sender;


@end
