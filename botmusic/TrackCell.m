//
//  TrackCell.m
//  botmusic
//
//  Created by Илья Романеня on 18.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "TrackCell.h"
#import <UIImageView+AFNetworking.h>
#import "NDMusicControl.h"
#import "UIImageView+WebCache_FadeIn.h"

static NSString * const kTrackStateKeyPath = @"trackItem.trackState";

@interface TrackCell()

@property (nonatomic, strong) NDMusicControl*   musicControl;
@property (nonatomic, strong) MFTrackItem*      trackItem;

@end

@implementation TrackCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createActionView];
        
        [self addObserver:self forKeyPath:kTrackStateKeyPath
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [self createActionView];
    
    UITapGestureRecognizer *tapImage=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtUserThumb:)];
    [self.postedByImage addGestureRecognizer:tapImage];
    
    UITapGestureRecognizer *tapLabel=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtUserThumb:)];
    [self.postedViaLabel addGestureRecognizer:tapLabel];
    
    self.postedByImage.layer.cornerRadius = self.postedByImage.frame.size.width / 2;
    self.postedByImage.clipsToBounds=YES;
    
    [self.sliderView setSliderViewDelegate:self];
    
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    
    [self createMusicControl];
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

- (void)dealloc
{
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
}

#pragma mark - MusicControl methods

- (void)createMusicControl
{
    CGFloat musicControlSize = 50;
    _musicControl = [[NDMusicControl alloc] initWithFrame:CGRectMake(CGRectGetMidX(_trackImage.bounds) - musicControlSize/2,
                                                                     CGRectGetMidY(_sliderView.upperView.bounds) - musicControlSize/2,
                                                                     musicControlSize,
                                                                     musicControlSize)];
    _musicControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_musicControl addTarget:self action:@selector(musicControlTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [_sliderView.upperView addSubview:_musicControl];
    _musicControl.hidden = NO;
}

- (void)trackStateChanged:(NDMusicConrolStateType)state
{
    [_musicControl changePlayState:state];
}

- (void)musicControlTouched
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnView:)]) {
        [_delegate didTapOnView:_trackItem];
    }
}

#pragma mark - TapRecognizer methods

-(void)didTapAtUserThumb:(UITapGestureRecognizer*)tap
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectShowFriend:)])
    {
        [_delegate didSelectShowFriend:_trackItem];
    }
}

#pragma mark - ActionView Methods

-(void)createActionView
{
    _actionView=[ActionViewCreator createActionViewInView:self];
    [_actionView setDelegate:self];
}

#pragma mark - Info Setters

- (void)setTrackInfo:(MFTrackItem *)trackItem
{
    [self setValue:trackItem forKey:@"trackItem"];
    
    [self clearSubviews];
    [self.sliderView setOpenWidth:80.0f];

    self.trackImage.image = nil;
    NSURL* trackURL = [NSURL URLWithString:trackItem.trackPicture];
    if (trackURL)
    {
        [self.trackImage sd_setImageAndFadeOutWithURL:trackURL placeholderImage:[UIImage imageNamed:@"NoImage.png"]];
    }
    if (trackItem.artist.length)
    {
        self.artistNameLabel.text = trackItem.artist;
        self.trackNameLabel.text = trackItem.trackName;
    }
    else
    {
        self.artistNameLabel.text = trackItem.trackName;
    }
    
    if ([trackItem isHaveVideo])
    {
        self.playVideoButton.hidden = NO;
    }
    else
    {
        self.playVideoButton.hidden = YES;
    }
    
    self.likeCountLabel.text = [trackItem.likes stringValue];
    self.commentCountLabel.text=[trackItem.comments stringValue];
    [self setIsLiked:trackItem.isLiked];
    
    self.postedByImage.image = nil;
    NSURL* authorURL = [NSURL URLWithString:trackItem.authorPicture relativeToURL:BASE_URL];
    if (authorURL)
    {
        [self.postedByImage sd_setImageAndFadeOutWithURL:authorURL placeholderImage:[UIImage imageNamed:@"NoImage.png"]];
    }
    
    self.postedViaLabel.text=[NSString stringWithFormat:@"@%@ via %@",[trackItem username],[trackItem.type capitalizedString]];
    [self.postTimeLabel setText:[trackItem.timestamp timeAgo]];
    
    if([trackItem.type isEqualToString:feedTypeYoutube])
    {
        _trackLink=trackItem.link;
    }
    else
    {
        _trackLink=trackItem.youtubeLink;
    }
    
    [self trackStateChanged:(NDMusicConrolStateType)_trackItem.trackState];
}
- (void)clearSubviews
{
   // self.trackImage.image = ;
    self.artistNameLabel.text = @"";
    self.trackNameLabel.text = @"";
    self.likeCountLabel.text = @"";
    self.postedByImage.image = nil;
    
    [self.sliderView  closeSliderAnimated:NO];
}
-(void)setIsLiked:(BOOL)isLiked
{
    if(isLiked)
    {
        [_likeCountLabel setTextColor:[UIColor selectedColor]];
    }
    else
    {
        [_likeCountLabel setTextColor:[UIColor unselectedColor]];
    }
    
    [_likeButton setSelected:isLiked];
    
    _isLiked=isLiked;
}
- (void)setCanLike:(BOOL)canLike{
    
    [self.likeButton setUserInteractionEnabled:canLike];
}

#pragma mark - Actions

- (IBAction)didSelectShare:(id)sender
{
    [self.delegate didShare:_trackItem];
}
-(IBAction)didSelectLike:(id)sender
{
    if(_isLiked)
    {
        [self.delegate didUnlike:_trackItem];
    }
    else
    {
        [self.delegate didLike:_trackItem];
//        [_actionView makeAnimation];
    }
}
-(IBAction)didSelectComment:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectComment:)])
    {
        [_delegate didSelectComment:self.indexPath];
    }
}
- (IBAction)didTouchUpDeleteButton:(id)sender
{
//    if(_delegate && [_delegate respondsToSelector:@selector(didDelete:)])
//    {
//        [_delegate didDelete:self.indexPath];
//    }
}

#pragma mark - Notification center events

-(void)playerWillExitFullscreen:(MPMoviePlayerController*)player
{
    AppDelegate *delegate=[NSObject appDelegate];
    [delegate setIsShowVideo:NO];
    
    [self.playVideoButton setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SSSliderView Delegate methods

-(void)willOpenSlider
{
//    if(self.delegate && [self.delegate respondsToSelector:@selector(didOpenDelete:)])
//    {
//        [self.delegate didOpenDelete:self.indexPath];
//    }
}
-(void)didCloseSlider
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didCloseDelete:)]){
        //[self.delegate didCloseDelete:self];
    }
}

@end
