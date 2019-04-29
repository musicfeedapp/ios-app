//
//  MFSuggestionTableViewCell.m
//  botmusic
//
//  Created by Vladimir on 27.11.15.
//
//

#import "MFSuggestionTableViewCell.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "MFSuggestionTrackCollectionViewCell.h"
#import "MFNotificationManager.h"
static UIImage* defaultArtwork;
static NSInteger cellsNumber;

@implementation MFSuggestionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.tracksCollectionView.dataSource = self;
    self.tracksCollectionView.delegate = self;
    if (!cellsNumber) {
        cellsNumber = (int)([UIScreen mainScreen].bounds.size.width - 20.0)/70.0;
    }
    self.tracksCollectionViewFlowLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20.0)/cellsNumber, 89);
    UINib *trackSmall = [UINib nibWithNibName:@"MFSuggestionTrackCollectionViewCell" bundle:nil];
    [self.tracksCollectionView registerNib:trackSmall forCellWithReuseIdentifier:@"MFSuggestionTrackCollectionViewCell"];
    if (!defaultArtwork) {
        defaultArtwork = [UIImage imageNamed:@"DefaultArtwork"];
    }
    [_commonFollowersTappableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commonFollowersTap)]];
}

- (void)setSuggestion:(MFSuggestion *)suggestion{
    _suggestion = suggestion;
    self.background.image = nil;
    [self.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
        self.background.image = image;
    }];
    self.nameLabel.text = suggestion.name;
    self.followButton.hidden = suggestion.is_followed;
    self.verifiedMark.hidden = !suggestion.is_verified;
    self.verifiedBarkground.hidden = !suggestion.is_verified;
    NSMutableString* commonFollowers = [NSMutableString string];
    NSUInteger number = 0;

    for (MFFollowItem* followItem in suggestion.commonFollowers) {
        if (commonFollowers.length) {
            [commonFollowers appendString:@", "];
        }
        [commonFollowers appendString:[followItem name]];
        number++;
        if (number==3) {
            break;
        }
    }

    _commonFollowersLabel.text = commonFollowers;
    if (suggestion.commonFollowers.count>number) {
        _otherCommonFollowersLabel.hidden = NO;
        _otherCommonFollowersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"and %lu others", nil), suggestion.commonFollowers.count - number];
    } else {
        _otherCommonFollowersLabel.text = @"";
        _otherCommonFollowersLabel.hidden = YES;
    }

    if ([self.tracksCollectionView numberOfItemsInSection:0] != MIN(cellsNumber, _suggestion.timelines.count)) {
        [self.tracksCollectionView reloadData];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray* visibleCells = _tracksCollectionView.visibleCells;
            for (int i = 0; i < MIN(visibleCells.count, suggestion.timelines.count); i++) {
                MFSuggestionTrackCollectionViewCell* cell = visibleCells[i];
                MFTrackItem* track = suggestion.timelines[[_tracksCollectionView indexPathForCell:cell].row];
                cell.trackNameLabel.text = track.trackName;
                [cell.trackImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:track.trackPicture] placeholderImage:defaultArtwork];
                cell.track = track;
            }

        });
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    UIColor* buttonColor = self.followButton.backgroundColor;
    UIColor* grayViewColor = self.grayView.backgroundColor;
    UIColor* separatorColor = self.separatorView.backgroundColor;
    UIColor* separator2Color = self.separator2View.backgroundColor;

    [super setSelected:selected animated:animated];
    
    self.followButton.backgroundColor = buttonColor;
    self.grayView.backgroundColor = grayViewColor;
    self.separatorView.backgroundColor = separatorColor;
    self.separator2View.backgroundColor = separator2Color;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    UIColor* buttonColor = self.followButton.backgroundColor;
    UIColor* grayViewColor = self.grayView.backgroundColor;
    UIColor* separatorColor = self.separatorView.backgroundColor;
    UIColor* separator2Color = self.separator2View.backgroundColor;

    [super setHighlighted:highlighted animated:animated];
    self.followButton.backgroundColor = buttonColor;
    self.grayView.backgroundColor = grayViewColor;
    self.separatorView.backgroundColor = separatorColor;
    self.separator2View.backgroundColor = separator2Color;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // Configure the view for the selected state
}
- (IBAction)followButtonTapped:(id)sender {
    [self.delegate suggestionTableViewCellDidSelectFollow:self];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(cellsNumber, _suggestion.timelines.count);
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MFSuggestionTrackCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFSuggestionTrackCollectionViewCell" forIndexPath:indexPath];
    
    MFTrackItem* track = self.suggestion.timelines[indexPath.row];
    
    cell.trackNameLabel.text = track.trackName;
    [cell.trackImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:track.trackPicture]];
    cell.track = track;
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    MFTrackItem* track = self.suggestion.timelines[indexPath.row];
    
    if (![playerManager.currentTrack isEqual:track]) {
        [playerManager playPlaylist:[self.suggestion.timelines array] fromIndex:(int)indexPath.row];
        playerManager.currentSourceName = [NSString stringWithFormat:@"%@ — %@", self.suggestion.name, @"POSTS"];

    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
    
}

- (void)commonFollowersTap{
    [_delegate suggestionTableViewCellDidSelectCommonFollowers:self];
}
@end
