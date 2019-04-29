//
//  CommentsTrackView.m
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CommentsTrackView.h"
#import "UIColor+Expanded.h"
#import "UIImage+Resize.h"
#import "NDMusicControl.h"
#import "UIImageView+WebCache_FadeIn.h"

static NSString *const WHITE_VIDEO_ICON=@"Video.png";
static NSString *const DARK_VIDEO_ICON=@"VideoDark.png";
static NSString * const kTrackStateKeyPath = @"trackItem.trackState";


@interface CommentsTrackView()

@property (nonatomic, strong)   CAGradientLayer*  gradient;
@property (nonatomic, strong)   NDMusicControl*   musicControl;
@property (nonatomic, strong)   MFTrackItem*      trackItem;

@end

@implementation CommentsTrackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:kTrackStateKeyPath
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:nil];
    }
    return self;
}

+ (CommentsTrackView*)createTrackView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"CommentsTrackView" owner:nil options:nil]lastObject];
}

#pragma mark - Settings Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    
    [self defaultSettings];
}

- (void)dealloc {
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
}

- (void)defaultSettings
{    
    [self createActionView];
    
    [self roundUserImage];
    
    [self createMusicControl];
}

- (void)createActionView
{
    _actionView=[ActionViewCreator createActionViewInView:self];
    [_actionView setDelegate:self];
}

- (void)roundUserImage
{
    _autorImageView.layer.cornerRadius = _autorImageView.frame.size.width / 2;
    _autorImageView.clipsToBounds=YES;
}

- (void)createMusicControl
{
    CGFloat musicControlSize = 50;
    _musicControl = [[NDMusicControl alloc] initWithFrame:CGRectMake(CGRectGetMidX(_upperView.bounds) - musicControlSize/2,
                                                                     COMMENTS_TRACK_VIEW_HEIGHT/2 - musicControlSize/2 - 30,
                                                                     musicControlSize,
                                                                     musicControlSize)];
    _musicControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_musicControl addTarget:self action:@selector(musicControlTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [_upperView addSubview:_musicControl];
    _musicControl.hidden = !_tapEnable;
}

- (void)setTrackViewHeight:(CGFloat)height
{
    
    CGRect frame=self.trackImage.frame;
    
    frame.size.height=height;
    frame.origin.y=0;
    
    if(height >= COMMENTS_TRACK_VIEW_HEIGHT){
        
        [self.blurView setAlpha:0.0f];
        CGFloat coeficient=height/COMMENTS_TRACK_VIEW_HEIGHT;
        
        frame.size.width=CGRectGetWidth([[UIScreen mainScreen]bounds])*coeficient;
        frame.origin.x=-(frame.size.width-CGRectGetWidth([[UIScreen mainScreen]bounds]))/2;
        
        CGFloat delta=COMMENTS_TRACK_VIEW_HEIGHT/2+height-COMMENTS_TRACK_VIEW_HEIGHT;
        
        CGRect infoFrame=self.infoView.frame;
        infoFrame.origin.y=delta;
        [self.infoView setFrame:infoFrame];
        
        CGRect autorImageFrame=self.autorImageView.frame;
        autorImageFrame.origin.y=infoFrame.origin.y + 21.0f;
        [self.autorImageView setFrame:autorImageFrame];
    }
    else{
        CGFloat coeficient=(COMMENTS_TRACK_VIEW_HEIGHT-height)/COMMENTS_TRACK_VIEW_HEIGHT;
        NSLog(@"%f",coeficient);
        [self.blurView setAlpha:(COMMENTS_TRACK_VIEW_HEIGHT-height)/COMMENTS_TRACK_VIEW_HEIGHT+0.2f];
        [self.blurView setBlurRadius:15.0f];
        
        frame.size.height=COMMENTS_TRACK_VIEW_HEIGHT;
        frame.origin.y=-(COMMENTS_TRACK_VIEW_HEIGHT-height)/2;
        
        CGRect infoFrame=self.infoView.frame;
        infoFrame.origin.y=frame.size.height-(COMMENTS_TRACK_VIEW_HEIGHT-height)/2-infoFrame.size.height;
        [self.infoView setFrame:infoFrame];
        
        CGRect autorImageFrame=self.autorImageView.frame;
        autorImageFrame.origin.y=infoFrame.origin.y + 21.0f;
        [self.autorImageView setFrame:autorImageFrame];
    }
    
    [self.trackImage setFrame:frame];
    
    if (_gradient != nil) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        frame=_gradient.frame;
        frame.origin.y=height - COMMENTS_TRACK_VIEW_HEIGHT + _upperView.bounds.size.height/3;
        [_gradient setFrame:frame];
        
        [CATransaction commit];
    }
}

- (void)setShowGradient:(BOOL)showGradient
{
    if (!_showGradient) {
        _showGradient = YES;
        
        if (_gradient == nil) {
            _gradient = [CAGradientLayer layer];
        }
        
        _gradient.frame = CGRectMake(0, _upperView.frame.size.height/3, _upperView.frame.size.width, _upperView.frame.size.height/3*2);
        UIColor *startColour = [UIColor colorWithWhite:0 alpha:0];
        UIColor *endColour = [UIColor colorWithWhite:0 alpha:0.4];
        _gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
        [_upperView.layer insertSublayer:_gradient below:_infoView.layer];
    }
}

- (void)setTapEnable:(BOOL)tapEnable
{
    _tapEnable = tapEnable;
    self.musicControl.hidden = !tapEnable;
}


#pragma mark - Footer methods

- (void)openFooterViewAnimated:(BOOL)animated
{
    CGRect authorFrame=_autorImageView.frame;
    authorFrame.origin.y=165;
    
    CGRect userNameFrame=_usernameLabel.frame;
    userNameFrame.origin.x = 15;
    userNameFrame.size.width=299;
    
    CGRect trackNameFrame=_trackNameLabel.frame;
    trackNameFrame.origin.x = 15;
    trackNameFrame.size.width=299;
    
    if(animated)
    {
        [UIView animateWithDuration:0.2 animations:^
         {
             _autorImageView.frame=authorFrame;
             _usernameLabel.frame=userNameFrame;
             _trackNameLabel.frame=trackNameFrame;
         }completion:^(BOOL finished)
         {
             _isFooterOpen=YES;
         }];
    }
    else
    {
        _autorImageView.frame=authorFrame;
        _usernameLabel.frame=userNameFrame;
        _trackNameLabel.frame=trackNameFrame;
        _isFooterOpen=YES;
    }
}

- (void)closeFooterView
{
    CGRect userNameFrame=_usernameLabel.frame;
    userNameFrame.origin.x = 15;
    userNameFrame.size.width=244;
    
    CGRect trackNameFrame=_trackNameLabel.frame;
    trackNameFrame.origin.x = 15;
    trackNameFrame.size.width=299;
    trackNameFrame.size.height=42;
    self.trackNameLabel.numberOfLines=2;
    self.trackNameLabel.lineBreakMode=NSLineBreakByWordWrapping;
    
    _usernameLabel.frame=userNameFrame;
    _trackNameLabel.frame=trackNameFrame;
    _isFooterOpen=NO;
}

#pragma mark - Track Info

- (void)setTrackInfo:(MFTrackItem *)trackItem
{
    [self setValue:trackItem forKey:@"trackItem"];
    
    _trackNameLabel.text=trackItem.trackName;
    
    NSURL* cellUrl = [NSURL URLWithString:trackItem.trackPicture];
    if (cellUrl != nil) {
        //[[MFAppImageManager sharedManager] startImageDowloadingForUrl:cellUrl preprocessType:MFAppManagerImagePreprocessTypeCell];
        [_trackImage sd_setImageAndFadeOutWithURL:cellUrl placeholderImage:[UIImage imageNamed:@"NoImage"]];
    }
    
    if (!self.isCommentsView) {
        NSURL* avatarUrl = [NSURL URLWithString:trackItem.authorPicture relativeToURL:BASE_URL];
        if (avatarUrl != nil) {
            //[[MFAppImageManager sharedManager] startImageDowloadingForUrl:avatarUrl preprocessType:MFAppManagerImagePreprocessTypeAvatar];
            [_autorImageView sd_setImageAndFadeOutWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"NoImage"]];
        }
    }
    else {
        [self.autorImageView setHidden:YES];
    }
    
    if (self.isCommentsView) {
        [self.usernameLabel setHidden:YES];
        [self.trackNameLabel setFrame:self.usernameLabel.frame];
    }
    
    _usernameLabel.text=[NSString stringWithFormat:@"@%@ via %@",trackItem.username,[trackItem.type capitalizedString]];
    
    [self setLabelsColor:trackItem];
    
    [self setIsLiked:trackItem.isLiked];
    
    if(_isFooterOpen)
    {
        [self openFooterViewAnimated:NO];
    }
    else {
        [self closeFooterView];
    }
    
    if([trackItem.type isEqualToString:feedTypeYoutube])
    {
        _trackLink=trackItem.link;
    }
    else
    {
        _trackLink=trackItem.youtubeLink;
    }
    
    //TODO use trackState enum as externa for music control.
    [self trackStateChanged:_trackItem.trackState];
}
- (void)setLabelsColor:(MFTrackItem*)trackItem
{
    UIColor *color=[UIColor colorWithHexString:@"#FFFFFF"];
    
    [_trackNameLabel setTextColor:color];
    [_usernameLabel setTextColor:color];
    
    [self.videoButton setImage:[UIImage imageNamed:WHITE_VIDEO_ICON] forState:UIControlStateNormal];
}
- (void)setIsLiked:(BOOL)isLiked;
{
    _isLiked=isLiked;
}

- (void)trackStateChanged:(NDMusicConrolStateType)state
{
    [_musicControl changePlayState:state];
}

#pragma mark - Notification center events

- (void)playerWillExitFullscreen:(MPMoviePlayerController*)player
{
    AppDelegate *delegate=[NSObject appDelegate];
    [delegate setIsShowVideo:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;
    
    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

#pragma mark - actions

- (void)musicControlTouched
{
    if(_tapEnable)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(didTapOnView:)])
        {
            [_delegate didTapOnView:_indexPath];
        }
    }
}

- (void)didTouchUpRestoreButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnView:)])
    {
        [_delegate didRestoreDeleted:_indexPath];
    }
}

@end
