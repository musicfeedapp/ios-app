//
//  SuggestionCell.m
//  botmusic
//
//  Created by Supervisor on 12.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "SuggestionCell.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface SuggestionCell()

@property(nonatomic,weak)IBOutlet UIImageView *userImageView;
@property(nonatomic,weak)IBOutlet UILabel *usernameLabel;

@end

@implementation SuggestionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setIsMenuSearch:(BOOL)isMenuSearch
{
    if(isMenuSearch)
    {
        [self.usernameLabel setTextColor:[UIColor colorWithRed:183.0f/255 green:183.0f/255 blue:183.0f/255 alpha:1.0]];
    }
    else
    {
        [self.usernameLabel setTextColor:[UIColor colorWithRed:49.0f/255 green:49.0f/255 blue:49.0f/255 alpha:1.0]];
    }
    
    _isMenuSearch=isMenuSearch;
}

-(void)setSuggestionInfo:(IRSuggestion*)suggestion
{
    if(suggestion)
    {
        [self.usernameLabel setText:suggestion.name];
        [self.userImageView setImage:nil];
        [self.userImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url] placeholderImage:[UIImage imageNamed:@"NoImage.png"]];
    }
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.clipsToBounds = YES;
}

@end
