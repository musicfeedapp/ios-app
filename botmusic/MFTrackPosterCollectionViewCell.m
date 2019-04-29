//
//  MFTrackPosterCollectionViewCell.m
//  botmusic
//
//  Created by Panda Systems on 11/10/15.
//
//

#import "MFTrackPosterCollectionViewCell.h"

@implementation MFTrackPosterCollectionViewCell{
    BOOL _layoutConfigured;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_layoutConfigured) {
        _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.height/2.0;
        _layoutConfigured = YES;
    }
}
@end
