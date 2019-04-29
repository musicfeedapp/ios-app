//
//  ImportArtistsViewController.m
//  botmusic
//

#import "ImportArtistsViewController.h"
#import "MusicLibary.h"
#import "ImportArtistTableCell.h"
#import "MFNotificationManager.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface ImportArtistsViewController ()

@property (nonatomic, strong) NSArray *artists;

@end

@implementation ImportArtistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupArtists];
    
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

#pragma mark - Setup

- (void)setupArtists
{
    NSArray *artists;
    if (self.importSource == MFImportSourceMusicLibrary) {
        artists = [MusicLibary iTunesMusicLibaryArtists];
    }
    else {
        artists = [[NSArray alloc] init];
    }
    self.artists = artists;
    
    [self.artistsTableView reloadData];
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.artists.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ImportArtistTableCell";
    
    ImportArtistTableCell *cell = (ImportArtistTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ImportArtistTableCell" owner:nil options:nil] lastObject];
    }
    
    cell.artistNameLabel.text = self.artists[indexPath.row];
    [cell.artistImageView sd_setImageAndFadeOutWithURL:nil
                                          placeholderImage:[UIImage imageNamed:@"NoImage"]];

    
    return cell;
}

#pragma mark - Button Touches

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.artistsTableView numberOfRowsInSection:0] > 0) {
        [self.artistsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
