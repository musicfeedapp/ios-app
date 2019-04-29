//
//  MFSuggestionSmallCollectionViewCell.m
//  botmusic
//
//  Created by Vladimir on 27.11.15.
//
//

#import "MFSuggestionSmallCollectionViewCell.h"

@implementation MFSuggestionSmallCollectionViewCell{
    BOOL _layoutConfigured;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_layoutConfigured) {
        _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.height/2.0;
        _layoutConfigured = YES;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

@end
