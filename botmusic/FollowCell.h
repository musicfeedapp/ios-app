//
//  FollowCell.h
//  botmusic
//
//  Created by Илья Романеня on 08.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFFollowItem+Behavior.h"

@class FollowCell;

@protocol FollowCellDelegate <NSObject>

@required

- (void)changeFollowing:(FollowCell *)sender;
- (BOOL)following:(FollowCell *)sender;

@end

extern const NSUInteger followCellMainViewTag;

@interface FollowCell : UITableViewCell

@property (nonatomic, weak) id <FollowCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIImageView* userImageView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackCountLabel;
@property (nonatomic, weak) IBOutlet UIButton* followButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* followActivityIndicator;

@property (nonatomic, strong) NSIndexPath* indexPath;

- (void)setFollowItem:(MFFollowItem*)followItem buttonHidden:(BOOL)buttonHidden;
- (void)startProcessing;
- (void)stopProcessing;

- (IBAction)followTap:(id)sender;
@end
