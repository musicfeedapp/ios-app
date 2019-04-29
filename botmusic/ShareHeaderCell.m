//
//  ShareCell.m
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ShareHeaderCell.h"

@implementation ShareHeaderCell

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

- (void)refreshViews
{
    self.facebookButton.selected = [self.delegate isFacebookShared:self];
    self.twitterButton.selected = [self.delegate isTwitterShared:self];
}

- (IBAction)facebookTap:(id)sender
{
    if (![self.delegate isFacebookShared:self])
    {
        [self.delegate shareOnFacebook:self
                       completionBlock:^
         {
             self.facebookButton.selected = [self.delegate isFacebookShared:self];
         }];
    }
}

- (IBAction)twitterTap:(id)sender
{
    if (![self.delegate isFacebookShared:self])
    {
        [self.delegate shareOnTwitter:self
                      completionBlock:^
         {
             self.twitterButton.selected = [self.delegate isTwitterShared:self];
         }];
    }
}

@end
