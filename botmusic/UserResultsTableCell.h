//
//  UserResultsTableCell.h
//  botmusic
//
//  Created by Panda Systems on 1/22/15.
//
//

#import <UIKit/UIKit.h>

@class IRSuggestion;

@protocol UserResultsTableCellDelegate <NSObject>

- (void)didChangeFollowing:(IRSuggestion *)suggestion;

@end

@interface UserResultsTableCell : UITableViewCell

@property (nonatomic, weak) id<UserResultsTableCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tracksLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UILabel *verifiedMarkLabel;

@property (nonatomic, strong) IRSuggestion *suggestion;
@property (nonatomic, assign) BOOL isArtist;

- (IBAction)didTouchUpFollowButton:(id)sender;

- (void)setInfo:(IRSuggestion*)suggestion;

@end
