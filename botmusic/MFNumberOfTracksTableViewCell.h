//
//  MFNumberOfTracksTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 9/4/15.
//
//

#import <UIKit/UIKit.h>

@interface MFNumberOfTracksTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;

@end
