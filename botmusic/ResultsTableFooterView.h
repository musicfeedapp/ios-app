//
//  ResultsTableFooterView.h
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import <UIKit/UIKit.h>

@protocol ResultsTableFooterDelegate <NSObject>

- (void)didSelectMoreTracks:(NSUInteger)section;

@end

@interface ResultsTableFooterView : UIView

@property (nonatomic, weak) id<ResultsTableFooterDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *moreTracksButton;

@property (nonatomic, assign) NSUInteger section;

- (IBAction)didTouchUpMoreTracksButton:(id)sender;

+ (ResultsTableFooterView *)createResultsTableFooterView;

@end
