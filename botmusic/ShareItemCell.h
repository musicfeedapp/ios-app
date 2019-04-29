//
//  ShareItemCell.h
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* itemImageView;
@property (nonatomic, weak) IBOutlet UILabel* label;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, assign) BOOL processing;

@end
