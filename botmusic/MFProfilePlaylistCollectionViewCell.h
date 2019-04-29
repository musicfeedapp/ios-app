//
//  MFProfilePlaylistCollectionViewCell.h
//  botmusic
//
//  Created by Panda Systems on 1/15/16.
//
//

#import <UIKit/UIKit.h>

@interface MFProfilePlaylistCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *heart;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeft;

@end
