//
//  ImportViewController.m
//  botmusic
//

#import "ImportViewController.h"
#import "ImportArtistsViewController.h"
#import "ImportTableCell.h"
#import "MFNotificationManager.h"

@interface ImportViewController ()

@property (nonatomic, strong) NSArray *importSources;

@end

@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.importSources = @[@(MFImportSourceMusicLibrary)];
    [self.importSourcesTableView reloadData];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.importSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ImportTableCell";
    
    ImportTableCell *cell = (ImportTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ImportTableCell" owner:nil options:nil] lastObject];
    }
    
    // TODO: set cell text
    
    return cell;
}

#pragma mark - Button Touches

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showImportedArtists"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ImportArtistsViewController *destViewController = segue.destinationViewController;
        destViewController.importSource = (MFImportSource)[[self.importSources objectAtIndex:indexPath.row] intValue];
    }
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.importSourcesTableView numberOfRowsInSection:0] > 0) {
        [self.importSourcesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
