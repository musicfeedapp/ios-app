//
//  SettingCell.h
//  botmusic
//
//  Created by Supervisor on 19.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingCell;

@protocol SettingsCellDelegate <NSObject>

-(void)didSwitchAtIndexPath:(SettingCell*)cell;

@end

@interface SettingCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UISwitch *switcher;

@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,weak)IBOutlet id<SettingsCellDelegate> delegate;

- (void)drawLowerSeparator;
-(void)drawTopAndBottomSeparator;

-(IBAction)didSwitcherChangeValue:(id)sender;

@end
