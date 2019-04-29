//
//  ShareItemCell.m
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ShareItemCell.h"

@implementation ShareItemCell

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

- (void)setProcessing:(BOOL)processing
{
    if (processing)
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
}

- (BOOL)processing
{
    return self.activityIndicator.isAnimating;
}
@end
