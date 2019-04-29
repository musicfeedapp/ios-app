//
//  TrackCell.h
//  botmusic
//
//  Created by Илья Романеня on 18.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTrackItem+Behavior.h"
#import "ActionView.h"
#import "ActionViewCreator.h"
#import "TrackView.h"

@interface TrackCell : UITableViewCell<ActionViewDelegate, SSSliderViewDelegate>

@property (nonatomic, weak) id <TrackViewDelegate> delegate;

@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic, weak) IBOutlet SSSliderView *sliderView;
@property (nonatomic, weak) IBOutlet UIImageView* trackImage;
@property (nonatomic, weak) IBOutlet UILabel* artistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* postTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel* likeCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, weak) IBOutlet UIImageView* postedByImage;
@property (nonatomic, weak) IBOutlet UILabel *postedViaLabel;

@property (nonatomic, weak) IBOutlet UIButton* playVideoButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIView *playerView;

@property (nonatomic, copy)NSString *trackLink;

@property (nonatomic, assign)BOOL isLiked;

@property (nonatomic, strong)ActionView *actionView;

- (IBAction)didSelectShare:(id)sender;
- (IBAction)didSelectLike:(id)sender;
- (IBAction)didSelectComment:(id)sender;
- (IBAction)didTouchUpDeleteButton:(id)sender;

- (void)setTrackInfo:(MFTrackItem*)trackItem;
- (void)setCanLike:(BOOL)canLike;

@end
