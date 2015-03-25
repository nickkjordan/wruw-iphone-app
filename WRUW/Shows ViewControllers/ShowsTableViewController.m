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
#import "AFHTTPRequestOperationManager.h"

@interface ShowsTableViewController () {
    NSMutableArray *_objects;
    NSArray *_originalObjects;
    UIActivityIndicatorView *spinner;
    NSArray *sectionTitles;
    NSArray *sectionIndexTitles;
    NSMutableDictionary *programs;
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *parameters;
    if (dayOfWeek > 0) {
        parameters = @{@"filt-day": [NSString stringWithFormat:@"%d", dayOfWeek]};
    } else {
        parameters = @{@"filt-day": @"all"};
    }
    
    [manager POST:@"http://www.wruw.org/shows-schedule" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *showsParser = [TFHpple hppleWithHTMLData:responseObject];
        
        // 3
        NSString *showsXpathQueryString = @"//*[@id='main']/div/table[2]/tbody/tr";
        NSArray *showsNodes = [showsParser searchWithXPathQuery:showsXpathQueryString];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
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
            NSString *abbrWeekday = [[show.time componentsSeparatedByString:@":"] objectAtIndex:0];
            [dateFormatter setDateFormat:@"EEE"];
            NSDate *weekday =[dateFormatter dateFromString:abbrWeekday];
            [dateFormatter setDateFormat:@"EEEE"];
            show.day = [dateFormatter stringFromDate:weekday];
            
            // 7
            show.url = [[showInfo firstChildWithTagName:@"a"] objectForKey:@"href"];
            
            show.lastShowUrl = [[elementInformation[4] firstChildWithTagName:@"a"] objectForKey:@"href"];
        }
        
        // 8
        _originalObjects = [NSArray arrayWithArray:newShows];
        [self resetObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [self.tableView reloadData];
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)resetObjects {
    if (dayOfWeek > 0) {
        NSString *weekday = [sectionTitles objectAtIndex:dayOfWeek - 1];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"day", weekday];
        
        NSArray *matches = [_originalObjects filteredArrayUsingPredicate:predicate];
        _originalObjects = [NSMutableArray arrayWithArray:matches];
    }
    
    _objects = [NSMutableArray arrayWithArray:_originalObjects];
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
    sectionTitles = @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
    sectionIndexTitles = @[@"Su", @"Mo", @"Tu", @"We", @"Th", @"Fr", @"Sa"];
    
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
    
    self.tableView.dataSource = self;
    programs = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Results Updating delegate

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
        [self resetObjects];
    }
    
    [self.tableView reloadData];
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (dayOfWeek == 0) {
        return [sectionTitles count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (dayOfWeek == 0) {
        return [sectionTitles objectAtIndex:section];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dayOfWeek == 0) {
        NSString *weekday = [sectionTitles objectAtIndex:section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"day", weekday];
        
        NSArray *matches = [_objects filteredArrayUsingPredicate:predicate];
        (matches) ? [programs setObject:matches forKey:weekday] : nil;
        return [matches count];
    } else {
        return _objects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"ShowCell" bundle:nil] forCellReuseIdentifier:@"ShowCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"ShowCell"];
    }
    Show *item;
    if (programs.count > 0) {
        NSString *weekday = [sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionPrograms = [programs objectForKey:weekday];
        item = [sectionPrograms objectAtIndex:indexPath.row];
    } else {
        item = [_objects objectAtIndex:indexPath.row];
    }
    [cell configureForShow:item];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (dayOfWeek == 0) {
        return sectionIndexTitles;
    }
    else
        return nil;
}

@end
