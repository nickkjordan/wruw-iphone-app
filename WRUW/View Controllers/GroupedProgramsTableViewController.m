#import "GroupedProgramsTableViewController.h"
#import "ARAnalytics.h"

@interface GroupedProgramsTableViewController ()
{
    NSMutableArray *daysOfWeek;
}

@end

@implementation GroupedProgramsTableViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"programsSegue"]) {
        ShowsTableViewController *stvc = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        int day = (int)path.row;
        [stvc setDayOfWeek:day];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Programs"];
    [ARAnalytics event:@"Screen view"
        withProperties:@{ @"screen": @"Programs View" }];

    daysOfWeek = [[NSMutableArray alloc] initWithObjects:@"Any", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return @"Pick A Day";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return daysOfWeek.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [daysOfWeek objectAtIndex:indexPath.row];
    
    return cell;
}

@end
