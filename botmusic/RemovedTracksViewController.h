//
//  RemovedTracksViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/28/15.
//
//

#import "AbstractViewController.h"

@interface RemovedTracksViewController : AbstractViewController  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tracksTableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

- (IBAction)didTouchUpBackButton:(id)sender;

@end
