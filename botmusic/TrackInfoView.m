//
//  TrackInfoView.m
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import "TrackInfoView.h"

#import <UIColor+Expanded.h>

#import "MFTrackItem+Behavior.h"
#import <MFNotificationManager.h>

@implementation TrackInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentAdded:)
                                                 name: [MFNotificationManager nameForNotification:MFNotificationTypeCommentsCountChanged] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackLiked:)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLiked]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackDisliked:)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackDisliked]
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (TrackInfoView *)createTrackInfoView
{
    TrackInfoView* view = [[[NSBundle mainBundle]loadNibNamed:@"TrackInfoView" owner:nil options:nil] lastObject];
    return view;
}

- (void)setTrack:(MFTrackItem *)track
{
    _track = track;
    
    [self setTrackName:track.trackName];
    [self setDuration:track.authorName];
    self.commentsLabel.text = [NSString stringWithFormat:@"%d", [track.comments intValue]];
    self.likesLabel.text = [NSString stringWithFormat:@"%d", [track.likes intValue]];
    [self.likesButton setSelected:track.isLiked];
    self.downloadButton.hidden = !(_track && _track.iTunesLink && [_track.iTunesLink length]);
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
}

- (void)commentAdded:(NSNotification *)notification;
{
    
    NSString* trackID = [[notification userInfo] objectForKey:@"trackID"];
    if([trackID isEqualToString:self.track.itemId]){
        //self.track.lastActivityType = @"Comment";
        //self.track.lastActivityTime = [NSDate date];
        [self setTrack:self.track];
    }
    
}

- (void)setTrackName:(NSString *)trackName
{
    self.trackNameLabel.text = trackName;
    self.trackNameLabel.frame = CGRectMake(self.trackNameLabel.frame.origin.x, self.trackNameLabel.frame.origin.y, 280.0f, self.trackNameLabel.frame.size.height);
    [self.trackNameLabel sizeToFit];
    
    self.trackNameLabelTopConstraint.constant = (self.upperView.frame.size.height - self.trackNameLabel.frame.size.height - self.durationLabelHeightConstraint.constant)/2;
    self.trackNameLabelHeightConstraint.constant = self.trackNameLabel.frame.size.height;
    self.trackNameLabelWidthConstraint.constant = self.trackNameLabel.frame.size.width;

    [self layoutIfNeeded];
}

- (void)setDuration:(NSString *)duration
{
    self.durationLabel.text = duration;
    if (self.isPlayerInfo) {
        self.progressLabelTrailingConstraint.constant = -[UIScreen mainScreen].bounds.size.width/2 - 5.0f;
        self.durationLabelLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width/2 + 5.0f;
        
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        self.durationLabel.textAlignment = NSTextAlignmentLeft;
    }
    else {
        self.progressLabelTrailingConstraint.constant = -[UIScreen mainScreen].bounds.size.width/2 - 5.0f;
        self.durationLabelLeadingConstraint.constant = ([UIScreen mainScreen].bounds.size.width - self.durationLabelWidthConstraint.constant)/2;
        
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAuthorName:)];
        [self.durationLabel addGestureRecognizer:tapRecognizer];
    }
    
    [self layoutSubviews];
}

- (void)setProgress:(NSString *)progress
{
    self.progressLabel.text = progress;
}

- (void)setIsPlayerInfo:(BOOL)isPlayerInfo
{
    _isPlayerInfo = isPlayerInfo;
    
    if (isPlayerInfo) {
        self.trackNameLabel.textColor = [UIColor whiteColor];
        self.progressLabel.hidden = NO;
        self.shareButton.hidden = YES;
        self.playerShareButton.hidden = NO;
    }
    else {
        self.shareButton.hidden = NO;
        self.playerShareButton.hidden = YES;
        self.progressLabel.hidden = YES;
    }
}

#pragma mark - Button Touches

- (IBAction)didTouchUpCommentsButton:(id)sender
{
    if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(shouldShowComments:)]) {
        [self.trackInfoViewDelegate shouldShowComments:self.track];
    }
}

- (IBAction)didTouchUpLikesButton:(id)sender
{
    if (!self.likesButton.isSelected) {
        [self.track likeTrackItem];
        if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(didLikeTrack:)]) {
            [self.trackInfoViewDelegate didLikeTrack:self.track];
        }
    }
    else {
        [self.track dislikeTrackItem];
        if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(didUnlikeTrack:)]) {
            [self.trackInfoViewDelegate didUnlikeTrack:self.track];
        }
    }
    
    [self reloadLikes];
}

- (void) reloadLikes{
    self.likesLabel.text = [NSString stringWithFormat:@"%d", [self.track.likes intValue]];
    [self.likesButton setSelected:self.track.isLiked];
}

- (IBAction)didTouchUpShareButton:(id)sender
{
    if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(didSelectShare:)]) {
        [self.trackInfoViewDelegate didSelectShare:self.track];
    }
}

- (IBAction)didTouchUpAddButton:(id)sender
{
    if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(didAddTrackToPlaylist:)]) {
        [self.trackInfoViewDelegate didAddTrackToPlaylist:self.track];
    }
}

- (IBAction)didTouchUpDownloadButton:(id)sender
{
    if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(didSelectDownload:)]) {
        [self.trackInfoViewDelegate didSelectDownload:self.track];
    }
}

- (void)didTapOnAuthorName:(id)sender
{
    if (self.trackInfoViewDelegate && [self.trackInfoViewDelegate respondsToSelector:@selector(shouldOpenAuthorProfile:)]) {
        [self.trackInfoViewDelegate shouldOpenAuthorProfile:self.track];
    }
}
-(void) trackLiked:(NSNotification*) notification{
    NSString* trackId = [notification.userInfo valueForKey:@"trackID"];
    if ([trackId isEqualToString:_track.itemId]){
        if (!_track.isLiked){
            [_track likeTrackItem];
        }
        [self setTrack:_track];
    }
}

-(void) trackDisliked:(NSNotification*) notification{
    NSString* trackId = [notification.userInfo valueForKey:@"trackID"];
    if ([trackId isEqualToString:_track.itemId]){
        if (_track.isLiked){
            [_track dislikeTrackItem];
        }
        [self setTrack:_track];
    }
}
@end
