//
//  ShowsTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "ShowsTableViewController.h"

#import "TFHpple.h"
#import "Show.h"
#import "DisplayViewController.h"

@interface ShowsTableViewController () {
    NSMutableArray *_objects;
    NSArray *_originalObjects;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) ArrayDataSource *showsArrayDataSource;

@end

@implementation ShowsTableViewController

@synthesize dayOfWeek;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showDisplaySegue"]) {
        DisplayViewController *dvc = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        Show *c = [_objects objectAtIndex:path.row];
        
        [dvc setCurrentShow:c];
    }
}

-(void)loadShows {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.wruw.org/shows-schedule"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    // Note that the URL is the "action" URL parameter from the form.
    [request setHTTPMethod:@"POST"];
//    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request addValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
//    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    //this is hard coded based on your suggested values, obviously you'd probably need to make this more dynamic based on your application's specific data to send
    NSString *postString = [NSString stringWithFormat:@"filtday=%d&filt-genre=&filt-orderby=schedule", dayOfWeek];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length] + 1];
//    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        // 2
        TFHpple *showsParser = [TFHpple hppleWithHTMLData:data];
        
        // 3
        NSString *showsXpathQueryString = @"//*[@id='main']/div/table[2]/tbody/tr";
        NSArray *showsNodes = [showsParser searchWithXPathQuery:showsXpathQueryString];
        
        // 4
        NSMutableArray *newShows = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in showsNodes) {
            // 5
            Show *show = [[Show alloc] init];
            [newShows addObject:show];
            
            NSArray *elementInformation = [element childrenWithTagName:@"td"];
            
            TFHppleElement *showInfo = elementInformation[0];
            
            // 6
            show.title = [[[showInfo firstChildWithTagName:@"a"] firstChild] content];
            
            show.host = [[[elementInformation[1] firstChildWithTagName:@"a"] firstChild] content];
            
            show.genre = [[[elementInformation[2] firstChildWithTagName:@"a"] firstChild] content];
            
            show.time = [[elementInformation[3] firstChild] content];
            show.day = [[show.time componentsSeparatedByString:@":"] objectAtIndex:0];
            
            // 7
            show.url = [[showInfo firstChildWithTagName:@"a"] objectForKey:@"href"];
            
            show.lastShowUrl = [[elementInformation[4] firstChildWithTagName:@"a"] objectForKey:@"href"];
        }
        
        // 8
        _objects = newShows;
        _originalObjects = [NSArray arrayWithArray:newShows];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [self setupTableView];
        });

    }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = CGPointMake(super.view.frame.size.width / 2.0, super.view.frame.size.height / 2.0);
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [UIColor blueColor];
    [self.view addSubview:spinner];
    
    [spinner startAnimating];
    
    dispatch_queue_t myQueue = dispatch_queue_create("org.wruw.app", NULL);
    
    dispatch_async(myQueue, ^{ [self loadShows]; });

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchForText:(NSString *)searchText
{
    [_objects removeAllObjects];
    if (searchText.length > 0) {
        
        NSArray *keys = @[@"title", @"host", @"genre"];
        
        for (NSString *key in keys) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", key, searchText];
            
            NSArray *matches = [_originalObjects filteredArrayUsingPredicate:predicate];
            [_objects addObjectsFromArray:matches];
        }
    } else {
        _objects = [NSMutableArray arrayWithArray:_originalObjects];
    }
    
    [self setupTableView];
}

#pragma mark - Table view data source

- (void)setupTableView
{
    TableViewCellConfigureBlock configureCell = ^(ShowCell *cell, Show *show) {
        [cell configureForShow:show];
    };
    self.showsArrayDataSource = [[ArrayDataSource alloc] initWithItems:[NSMutableArray arrayWithArray:_objects]
                                                        cellIdentifier:@"ShowCell"
                                                    configureCellBlock:configureCell];
    self.tableView.dataSource = self.showsArrayDataSource;
    [self.tableView reloadData];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (dayOfWeek < 0) {
        return [NSArray arrayWithObjects:@"Su", @"Mo", @"Tu", @"We", @"Th", @"Fr", @"Sa", nil];
    }
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}

#pragma mark - Search Results Updating delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

@end
