//
//  TrackInfoViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/27/15.
//
//

#import "AbstractViewController.h"

@class TrackInfoView;
@class MFTrackItem;

@protocol TrackInfoPlayDelegate <NSObject>

- (void)didSelectPlay:(MFTrackItem *)trackItem;

@end

@interface TrackInfoViewController : AbstractViewController

@property (nonatomic, weak) id<TrackInfoPlayDelegate> playDelegate;
@property (nonatomic, weak) IBOutlet UITableView *actionsTableView;
@property (nonatomic, weak) IBOutlet UIView *upperView;
@property (nonatomic, weak) IBOutlet UIView *trackView;
@property (nonatomic, weak) IBOutlet UIImageView *trackImageView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *inputView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UITextField *commentTextField;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artworkHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artworkLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artworkRightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerViewInsideTableView;


@property (nonatomic, weak) TrackInfoView *trackInfoView;

@property (nonatomic, strong) MFTrackItem *trackItem;
@property (nonatomic) BOOL isShowingOnlyComments;

@property (nonatomic, assign) BOOL isCommentsView;

- (IBAction)didTouchUpBackButton:(id)sender;
- (IBAction)didTouchUpCloseButton:(id)sender;
- (IBAction)didTextFieldSelectDone:(id)sender;

@end
