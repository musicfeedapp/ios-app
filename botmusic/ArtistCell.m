//
//  ArtistCell.m
//  botmusic
//
//  Created by Supervisor on 29.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ArtistCell.h"
#import "UIImageView+WebCache_FadeIn.h"


@interface ArtistCell()

@property(nonatomic,weak)IBOutlet UIImageView *artistImageView;
@property(nonatomic,weak)IBOutlet UILabel *artistTagLabel;
@property(nonatomic,weak)IBOutlet UIView *fullView;
@property(nonatomic,weak)IBOutlet UILabel *artistTagFullLabel;
@property(nonatomic,weak)IBOutlet UILabel *genresLabel;
@property(nonatomic,weak)IBOutlet UIButton *playButton;
@property(nonatomic,weak)IBOutlet UIButton *followButton;

@property(nonatomic)BOOL isSelected;
@property (nonatomic, strong) CAGradientLayer* gradient;
@property (nonatomic, strong) NSString* extId;
@property (nonatomic, strong) IRSuggestion* suggestion;
@end

@implementation ArtistCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    self.followButton.layer.cornerRadius = 4.0;
    self.followButton.layer.borderWidth = 1.0;
    self.followButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.followButton setTitle:@"unfollow" forState:UIControlStateSelected];
}

-(void)setIsSelected:(BOOL)isSelected
{
    CGRect frame=_artistTagLabel.frame;
    
    if(isSelected)
    {
        frame.size.width=2*[ArtistCell sizeOfArtistCell]-frame.origin.x;
        self.showGradient = NO;
        //[_artistTagLabel setTextColor:[UIColor blackColor]];
        
    }
    else
    {
        frame.size.width=[ArtistCell sizeOfArtistCell]-frame.origin.x;
        [_playButton setSelected:NO];
        //[_artistTagLabel setTextColor:[UIColor whiteColor]];
    }
    [_fullView setFrame: CGRectMake(0.0, 0.0, 2*[ArtistCell sizeOfArtistCell], 2*[ArtistCell sizeOfArtistCell])];
    [_playButton setFrame:CGRectMake((_fullView.bounds.size.width-_playButton.bounds.size.width)/2, (_fullView.bounds.size.height-_playButton.bounds.size.height)/2, _playButton.bounds.size.width, _playButton.bounds.size.height)];
    [_fullView setHidden:!isSelected];
    [_artistTagLabel setHidden:isSelected];
    
    _artistTagLabel.frame=frame;
    
    _isSelected=isSelected;
    [self.followButton setSelected:self.suggestion.is_followed];
    NSString* title = [_followButton isSelected]?NSLocalizedString(@"unfollow", nil):NSLocalizedString(@"follow", nil);
    CGSize stringsize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [_followButton setFrame:CGRectMake([ArtistCell sizeOfArtistCell]*2.0 - stringsize.width - 15.0 ,[ArtistCell sizeOfArtistCell]*2.0 - stringsize.height - 15.0,stringsize.width + 7.0, stringsize.height+ 7.0)];
}

-(void)setArtistInfo:(IRSuggestion*)suggestion
{
    self.suggestion = suggestion;
    self.extId = suggestion.ext_id;
    __block UIImageView *imageView = self.artistImageView;
    [self.artistImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url]
                            placeholderImage:nil
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if (image) {
                                           [imageView setImage:image];
                                       } else {
                                           [imageView setImage:nil];
                                       }
                                       
                                       if (!self.isSelected) {
                                           [self setShowGradient:YES];
                                       }
                                   }];
    [self.artistTagLabel setText:[NSString stringWithFormat:@"@%@",suggestion.username]];
    [self.artistTagFullLabel setText:[NSString stringWithFormat:@"@%@",suggestion.username]];
    [self.genresLabel setText:[self genresWithHashTags:suggestion.genres]];
    
    [self.followButton setSelected:suggestion.is_followed];
    NSString* title = [_followButton isSelected]?NSLocalizedString(@"unfollow", nil):NSLocalizedString(@"follow", nil);
    CGSize stringsize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [_followButton setFrame:CGRectMake([ArtistCell sizeOfArtistCell]*2.0 - stringsize.width - 15.0 ,[ArtistCell sizeOfArtistCell]*2.0 - stringsize.height - 15.0,stringsize.width + 7.0, stringsize.height+ 7.0)];
    
    self.artistTagFullLabel.userInteractionEnabled = YES;
    [self.artistTagFullLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTagLabel)]];
    [self.genresLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTagLabel)]];
}
-(void)setFollowInfo:(MFFollowItem*)followItem{
    //[self.artistImageView setImageSquareCropAndCacheWithURL:[NSURL URLWithString:followItem.picture] replaceImage:[UIImage imageNamed:@"NoImage"]];
    [_artistImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:followItem.picture] placeholderImage:[UIImage imageNamed:@"NoImage"]];

    [self.artistTagLabel setText:[NSString stringWithFormat:@"@%@",followItem.username]];
    
    [self.followButton setHidden:YES];
    [self.playButton setHidden:YES];
    [self.genresLabel setHidden:YES];
}

#pragma mark - IB Actions

-(IBAction)didSelectPlay:(id)sender
{
    if(_playButton.isSelected)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectPause:)])
        {
            [_delegate didSelectPause:_indexPath];
        }
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectPlay:)])
        {
            [_delegate didSelectPlay:_indexPath];
        }
    }
    
    [_playButton setSelected:!_playButton.isSelected];
}
-(IBAction)didSelectFollow:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectFollow:)])
    {
        [_delegate didSelectFollow:_indexPath];
    }
    
    [_followButton setSelected:!_followButton.isSelected];
    NSString* title = [_followButton isSelected]?NSLocalizedString(@"unfollow", nil):NSLocalizedString(@"follow", nil);
    CGSize stringsize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [_followButton setFrame:CGRectMake([ArtistCell sizeOfArtistCell]*2.0 - stringsize.width - 15.0 ,[ArtistCell sizeOfArtistCell]*2.0 - stringsize.height - 15.0,stringsize.width + 7.0, stringsize.height+ 7.0)];
}

#pragma mark - Helpers

-(NSString*)genresWithHashTags:(NSArray*)genres
{
    NSMutableString *genresString=[NSMutableString string];
    
    for(NSString *genre in genres)
    {
        [genresString appendString:[NSString stringWithFormat:@"#%@ ",genre]];
    }
    
    return genresString;
}

#pragma mark - Properties

- (void)setShowGradient:(BOOL)showGradient
{
    if ([_gradient superlayer]) {
        [_gradient removeFromSuperlayer];
    }
    
    if (showGradient) {
        _showGradient = YES;
        
        if (_gradient == nil) {
            _gradient = [CAGradientLayer layer];
        }
        CGFloat gragientWidth = [ArtistCell sizeOfArtistCell]/3;
        _gradient.frame = CGRectMake(0, gragientWidth, [ArtistCell sizeOfArtistCell], [ArtistCell sizeOfArtistCell] - gragientWidth);
        UIColor *startColour = [UIColor colorWithWhite:0 alpha:0];
        UIColor *endColour = [UIColor colorWithWhite:0 alpha:0.4];
        _gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
        [self.layer insertSublayer:_gradient below:_fullView.layer];
    }
}

+(int) sizeOfArtistCell{
    int j = (int)[UIScreen mainScreen].bounds.size.width%3;
    int i = (int)[UIScreen mainScreen].bounds.size.width/3;
    if (j!=0){
        i+=1;
    }
    return i;
}

-(void)handleTapOnTagLabel{
    if(_delegate && [_delegate respondsToSelector:@selector(showUserProfileWithUserInfo:)])
    {
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:self.extId];
        userInfo.extId = self.extId;
        [_delegate showUserProfileWithUserInfo:userInfo];
    }
}

@end
