#import "FavoriteShowsTableViewController.h"
#import "EmptyFavoritesView.h"
#import "WRUWModule-Swift.h"

@interface FavoriteShowsTableViewController ()
{
    NSMutableArray *_favorites;
}
@property (nonatomic, strong) ArrayDataSource *showsArrayDataSource;
@property (nonatomic, strong) UIView *emptyView;

@end

@implementation FavoriteShowsTableViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDisplaySegue"]) {
        DisplayViewController *dvc = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        Show *c = [_favorites objectAtIndex:path.row];
        
        [dvc setCurrentShow:c];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFavs];

    [self.tableView registerNib:[UINib nibWithNibName:@"ShowCell" bundle:nil ]
         forCellReuseIdentifier:@"ShowCell"];
}

-(void)checkIfEmpty {
    if (!_favorites.count) {
        _emptyView = [EmptyFavoritesView emptyShows];
        _emptyView.frame = self.view.frame;
        _emptyView.bounds = self.view.bounds;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_emptyView setAlpha:0.0];
        [self.view addSubview:_emptyView];
        [UIView animateWithDuration:0
                         animations:^{self->_emptyView.alpha = 1.0;
                         }];
    } else if ([_emptyView isDescendantOfView:self.view]) {
        [_emptyView removeFromSuperview];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadFavs];
    [self checkIfEmpty];
}

-(void)loadFavs {
    NSArray *favorites = [FavoriteManager.instance loadFavoriteShows];

    if (favorites.count == 0) {
        return;
    }

    _favorites = [favorites mutableCopy];

    [self setupTableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDisplaySegue" sender:self];
}

#pragma mark - Table view data source

- (void)setupTableView {
    TableViewCellConfigureBlock configureCell = ^(ShowCell *cell, Show *show) {
        [cell configureForShow:show];
    };

    self.showsArrayDataSource =
        [[ArrayDataSource alloc] initWithItems:_favorites
                                cellIdentifier:@"ShowCell"
                            configureCellBlock:configureCell];

    self.tableView.dataSource = self.showsArrayDataSource;
    [self.tableView reloadData];
}

@end
