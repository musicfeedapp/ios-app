//
//  ResultsTableHeaderView.h
//  botmusic
//
//  Created by Panda Systems on 1/22/15.
//
//

#import <UIKit/UIKit.h>

@interface ResultsTableHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+ (ResultsTableHeaderView *)createResultsTableHeaderView;

@end
