//
//  MFTrackView.m
//  botmusic
//
//  Created by Supervisor on 28.09.14.
//
//

#import "MFTrackView.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface MFTrackView()

@property (nonatomic, weak) IBOutlet UIImageView* trackImage;
@property (nonatomic, weak) IBOutlet UILabel* artistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* postTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel* likeCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, weak) IBOutlet UIImageView* postedByImage;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;

@end

@implementation MFTrackView

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
    [self createActionView];
    
    UITapGestureRecognizer *tapImage=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtUserThumb:)];
    [self.postedByImage addGestureRecognizer:tapImage];
    
    self.postedByImage.layer.cornerRadius = self.postedByImage.frame.size.width / 2;
    self.postedByImage.clipsToBounds=YES;
}

#pragma mark - TapRecognizer methods

-(void)didTapAtUserThumb:(UITapGestureRecognizer*)tap
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectShowFriend:)])
    {
        [_delegate didSelectShowFriend:self.indexPath];
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
    [self clearSubviews];
    
    self.trackImage.image = nil;
    NSURL* trackURL = [NSURL URLWithString:trackItem.trackPicture];
    if (trackURL)
    {
        [self.trackImage sd_setImageAndFadeOutWithURL:trackURL placeholderImage:[UIImage imageNamed:@"NoImage.png"]];
//        NSData *data = [NSData dataWithContentsOfURL:trackURL];
//        UIImage *img = [UIImage imageWithData:data];
//        if(img){
//            self.trackImage.image = img;
//        } else{
//            self.trackImage.image = [UIImage imageNamed:@"NoImage.png"];
//        }
        
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
    
    self.likeCountLabel.text = [trackItem.likes stringValue];
    self.commentCountLabel.text=[trackItem.comments stringValue];
    [self setIsLiked:trackItem.isLiked];
    
    self.postedByImage.image = nil;
    NSURL* authorURL = [NSURL URLWithString:trackItem.authorPicture relativeToURL:BASE_URL];
    if (authorURL)
    {
        [self.postedByImage sd_setImageAndFadeOutWithURL:authorURL];
    }

    [self.postTimeLabel setText:[trackItem.timestamp timeAgo]];
    
    if([trackItem.type isEqualToString:feedTypeYoutube])
    {
        _trackLink=trackItem.link;
    }
    else
    {
        _trackLink=trackItem.youtubeLink;
    }
}
- (void)clearSubviews
{
    // self.trackImage.image = ;
    self.artistNameLabel.text = @"";
    self.trackNameLabel.text = @"";
    self.likeCountLabel.text = @"";
    self.postedByImage.image = nil;
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
    [self.delegate didShare:self.indexPath];
}
-(IBAction)didSelectLike:(id)sender
{
    if(_isLiked)
    {
        [self.delegate didUnlike:self.indexPath];
    }
    else
    {
        [self.delegate didLike:self.indexPath];
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

@end
