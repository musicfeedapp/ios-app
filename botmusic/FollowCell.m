//
//  FollowCell.m
//  botmusic
//
//  Created by Илья Романеня on 08.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FollowCell.h"
#import "MFFollowItem+Behavior.h"
#import <UIImageView+AFNetworking.h>
#import "UIImage+Resize.h"
#import "UIImageView+WebCache_FadeIn.h"

@implementation FollowCell

const NSUInteger followCellMainViewTag = 22;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    self.userImageView.layer.cornerRadius=self.userImageView.frame.size.height/2;
    [self.userImageView setClipsToBounds:YES];
}

- (void)clearSubviews
{
    self.nameLabel.text = @"";
    self.trackCountLabel.text = @"";
    self.followButton.selected = NO;
}

- (void)setFollowItem:(MFFollowItem*)followItem buttonHidden:(BOOL)buttonHidden
{
    [self clearSubviews];
    
    self.nameLabel.text = followItem.name;
    
    CGRect frame=self.nameLabel.frame;
    
    if(followItem.isFollowed || followItem.timelineCount>0)
    {
        NSInteger postCount=followItem.timelineCount;
        NSString *postString=(followItem.timelineCount==1? NSLocalizedString(@"track",nil):NSLocalizedString(@"tracks",nil));
        self.trackCountLabel.text = [NSString stringWithFormat:@"%d %@",postCount,postString];
        
        frame.origin.y=10;
    }
    else
    {
        frame.origin.y=20;
    }
    
     [self.nameLabel setFrame:frame];
    
    self.userImageView.image = nil;

    NSString *urlString=[followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self.userImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:urlString relativeToURL:BASE_URL]];
    
    self.followButton.selected = !followItem.isFollowed;
    self.followButton.hidden = buttonHidden;
}

- (void)startProcessing
{
    [self.followActivityIndicator startAnimating];
    self.followButton.hidden = YES;
}

- (void)stopProcessing
{
    [self.followActivityIndicator stopAnimating];
    self.followButton.selected = ![self.delegate following:self];
    self.followButton.hidden = NO;
}

- (IBAction)followTap:(id)sender
{
    [self.delegate changeFollowing:self];
    self.followButton.selected = ![self.delegate following:self];
}
@end
