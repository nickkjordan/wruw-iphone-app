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
}

@end

@implementation ShowsTableViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showDisplaySegue"]) {
        DisplayViewController *dvc = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        Show *c = [_objects objectAtIndex:path.row];
        
        [dvc setCurrentShow:c];
    }
    
    
}

-(void)loadShows {
    // 1
    NSURL *showsUrl = [NSURL URLWithString:@"http://www.wruw.org/guide/index.php?form_submit=1&g=&d="];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    TFHpple *showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    // 3
    NSString *showsXpathQueryString = @"//body/table[2]/tr[1]/td/table/tr[2]/td[2]/table/tr[position()>1]";
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
        
        NSString *hostName = [[elementInformation[1] firstChild] content];
        hostName = [hostName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        hostName = [hostName stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        show.host = [hostName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *genre = [[elementInformation[2] firstChild] content];
        genre = [genre stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        genre = [genre stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        show.genre = [genre stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *time = [[elementInformation[3] firstChild] content];
        time = [time stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        time = [time stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        show.time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // 7
        show.url = [[showInfo firstChildWithTagName:@"a"] objectForKey:@"href"];
        
        show.lastShowUrl = [[elementInformation[4] firstChildWithTagName:@"a"] objectForKey:@"href"];
    }
    
    // 8
    _objects = newShows;
    [self.tableView reloadData];
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
    
    [self loadShows];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Show *thisShow = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = thisShow.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", thisShow.host, thisShow.time];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDisplaySegue" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
