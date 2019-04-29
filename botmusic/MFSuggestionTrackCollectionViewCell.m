//
//  MFSuggestionTrackCollectionViewCell.m
//  botmusic
//
//  Created by Vladimir on 27.11.15.
//
//

#import "MFSuggestionTrackCollectionViewCell.h"
#import "NDMusicControl.h"


static NSString * const kTrackStateKeyPath = @"track.trackState";

@implementation MFSuggestionTrackCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.playerIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:self.playerIndicatorContainer.bounds color:[UIColor whiteColor]];
    [self.playerIndicatorContainer addSubview:self.playerIndicator];
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;
    
    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            self.playerIndicator.hidden = YES;
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeLoading:
            self.playerIndicator.hidden = YES;
            self.activityIndicator.hidden = NO;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator startAnimating];
            break;
        case NDMusicConrolStateTypeFailed:
            self.playerIndicator.hidden = YES;
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePaused:
            self.playerIndicator.hidden = NO;
            [self.playerIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePlaying:
            self.playerIndicator.hidden = NO;
            [self.playerIndicator startAnimating];
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator stopAnimating];
            
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
    [self.playerIndicator stopAnimating];
}

@end
