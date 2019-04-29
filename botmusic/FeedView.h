//
//  FeedView.h
//  botmusic
//
//  Created by Dzionis Brek on 19.03.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "NavigationTitle.h"
#import "MFNotificationManager.h"
#import "MFRecognitionManager.h"

typedef enum : NSUInteger {
    MFFeedFilterTypeFeed,
    MFFeedFilterTypePosts,
    MFFeedFilterTypeTrending,
    MFFeedFilterTypeAudioOnly,
    MFFeedFilterTypeVideoOnly,
} MFFeedFilterType;


static CGFloat const NAVIGATION_BAR_HEIGHT=59.0f;

@protocol NavigationMenuDelegate <NSObject>

- (void)didSelectFeedType:(NSString*)feedType;
- (void)didSelectSearch;
- (void)didSelectClose;
- (void)setFeedFilterType:(MFFeedFilterType)feedFilterType;
@end

@protocol FeedSearchDelegate <NSObject>

- (void)setSearchMode:(BOOL)isSearchMode;
- (void)didBeginEditing:(id)sender;
- (void)didEditingChanged:(id)sender;
- (void)didCancelSearch;

@end

@interface FeedView : UIView <NavigationTitleDelegate, UITextFieldDelegate, MFRecognitionManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *suggestionsButton;
@property (nonatomic, weak) id <NavigationMenuDelegate> delegate;
@property (nonatomic, weak) id <FeedSearchDelegate> searchDelegate;

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIView *viewForMenu;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *topErrorView;
@property (weak, nonatomic) IBOutlet UILabel *topErrorViewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topErrorViewAlignment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *topErrorViewButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recognitionScrollIndicator;
@property (weak, nonatomic) IBOutlet UIButton *findPeopleButton;
@property (weak, nonatomic) IBOutlet UIView *findPeopleView;

@property (weak, nonatomic) IBOutlet UITableView *filtersTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *feedTypeArray;

@property (nonatomic) NavigationTitle *navigationTitle;

@property (nonatomic) REMenu *menu;
@property (nonatomic, assign) BOOL menuReady;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
- (IBAction)topErrorButtonClicked:(id)sender;
- (IBAction)addTrackButtonTapped:(id)sender;

- (IBAction)didTouchUpSearchButton:(id)sender;
+ (FeedView*)createFeedView;

@property (nonatomic) BOOL isInFilteringMode;
@property (nonatomic) NSInteger selectedFilterIndex;
@property (nonatomic, strong) NSArray* filters;
@end
