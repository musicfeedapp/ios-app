//
//  MenuCell.h
//  botmusic
//
//  Created by Supervisor on 14.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuCellDelegate <NSObject>

- (void)didHighlightCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MenuCell : UITableViewCell

@property (nonatomic, weak) id<MenuCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *suggestionCountLabel;

@property (nonatomic, strong) UIButton *badgeButton;

@property (nonatomic, assign) BOOL isProfileCell;
@property (nonatomic, assign) BOOL isSelected;

- (void)setSuggestionCount:(NSInteger)suggestionCount;
- (void)setBadgeNumber:(NSUInteger)number;
- (void)setTitle:(NSString *)title;

@end
