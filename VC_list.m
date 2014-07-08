//
//  VC_list.m
//  test
//
//  Created by darklinden on 14-4-26.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "VC_list.h"
#import "CSearchBar.h"

@implementation O_list_item

+ (id)itemTitle:(NSString *)title
{
    O_list_item *it = [[[self class] alloc] init];
    it.title = title;
    return it;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<O_dict_list_item: %p, title: %@>", self, self.title];
}

@end

typedef void (^ListSetupHandle)(SEL cancel, SEL done, NSArray **src_array);

@interface VC_list () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    ListSetupHandle setupHandle;
}

@property (nonatomic,   weak) IBOutlet CSearchBar   *pSearch;
@property (nonatomic,   weak) IBOutlet UIView       *pV_content;
@property (nonatomic,   weak) IBOutlet UITableView  *pVt_src;
@property (nonatomic,   weak) IBOutlet UIView       *pV_cover;
@property (nonatomic,   weak) IBOutlet UITableView  *pVt_search;

//data src
@property (nonatomic, strong) NSArray               *pArr_src;

@property (nonatomic, strong) NSMutableArray        *sectionsArray;
@property (nonatomic, strong) UILocalizedIndexedCollation *collation;

@property (nonatomic, strong) NSArray               *pArr_search;

@property (nonatomic, strong) O_list_item           *item_selected;

@end

@implementation VC_list

- (void)setup:(void (^)(SEL cancel, SEL done, NSArray **src_array))setup
{
    self->setupHandle = setup;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SEL cancel = @selector(pBtn_cancel_clicked:);
    SEL done = @selector(pBtn_done_clicked:);
    
    __block NSArray *array_src = nil;
    if (setupHandle) {
        setupHandle(cancel,
                    done,
                    &array_src);
    }
    
    self.pArr_src = array_src;
    
    clock_t start, end;
    double cpu_time_used;
    
    start = clock();
    
    _collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index, sectionTitlesCount = [[_collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
	
	// Segregate the time zones into the appropriate arrays.
	for (O_list_item *item in _pArr_src) {
        
		// Ask the collation which section number the time zone belongs in, based on its locale name.
		NSInteger sectionNumber = [_collation sectionForObject:item collationStringSelector:@selector(title)];
		
		// Get the array for the section.
		NSMutableArray *sections = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the time zone to the section.
		[sections addObject:item];
	}
	
	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
		
		NSMutableArray *charArrayForSection = [newSectionsArray objectAtIndex:index];
		
		NSArray *sortedCharArrayForSection = [_collation sortedArrayFromArray:charArrayForSection collationStringSelector:@selector(title)];
		
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedCharArrayForSection];
	}
    
    _sectionsArray = newSectionsArray;
    
    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    
    NSLog(@"sort using %lf second", cpu_time_used);
    
    [self.pVt_src reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!searchBar.showsCancelButton) {
        [self animate_show_search_display];
    }
    else {
        if (!searchBar.text.length) {
            self.pV_cover.hidden = NO;
            self.pVt_search.hidden = YES;
        }
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self animate_resign_search_display];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar isFirstResponder]) {
        if (searchText.length) {
            self.pV_cover.hidden = YES;
            self.pVt_search.hidden = NO;
            [self do_search:searchText];
        }
        else {
            self.pV_cover.hidden = NO;
            self.pVt_search.hidden = YES;
        }
    }
    else {
        self.pV_cover.hidden = YES;
        self.pVt_search.hidden = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.pVt_search]) {
        [self.pSearch resignFirstResponder];
    }
}

- (IBAction)pV_cover_did_taped:(id)sender {
    [self animate_resign_search_display];
}

- (void)animate_show_search_display
{
    [self.pSearch setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.pV_cover.hidden = NO;
    [UIView animateKeyframesWithDuration:0.2f
                                   delay:0.f
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:
     ^
     {
         CGRect rect = self.pSearch.frame;
         rect.origin.y = 0.f;
         self.pSearch.frame = rect;
         
         rect = self.pV_content.frame;
         rect.origin.y = self.pSearch.frame.size.height;
         rect.size.height = self.view.frame.size.height - rect.origin.y;
         self.pV_content.frame = rect;
         
         self.pV_cover.alpha = 1.f;
         
     } completion:^(BOOL finished)
     {
         [[UIApplication sharedApplication] setStatusBarHidden:YES];
         self.pVt_search.hidden = YES;
     }];
}

- (void)animate_resign_search_display
{
    [self.pSearch resignFirstResponder];
    self.pSearch.text = @"";
    [self.pSearch setShowsCancelButton:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateKeyframesWithDuration:0.2f
                                   delay:0.f
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:
     ^
     {
         CGRect rect = self.pSearch.frame;
         rect.origin.y = 20.f + 44.f;
         self.pSearch.frame = rect;
         
         rect = self.pV_content.frame;
         rect.origin.y = 20.f + 44.f + self.pSearch.frame.size.height;
         rect.size.height = self.view.frame.size.height - rect.origin.y;
         self.pV_content.frame = rect;
         
         if (!self.pV_cover.hidden) {
             self.pV_cover.alpha = 0.f;
         }
         
     } completion:^(BOOL finished)
     {
         self.pV_cover.hidden = YES;
         self.pV_cover.alpha = 1.f;
         self.pVt_search.hidden = YES;
         [[UIApplication sharedApplication] setStatusBarHidden:NO];
     }];
}

- (void)do_search:(NSString *)string
{
    NSPredicate *searchSearch = [NSPredicate predicateWithFormat:@"self.title CONTAINS[cd] %@", string];
    self.pArr_search = [self.pArr_src filteredArrayUsingPredicate:searchSearch];
    
    [self.pVt_search reloadData];
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.pVt_src]) {
        return [[_collation sectionTitles] count];
    }
    else if ([tableView isEqual:self.pVt_search]) {
        return 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.pVt_src]) {
        NSArray *rowsInSection = [_sectionsArray objectAtIndex:section];
        return [rowsInSection count];
    }
    else if ([tableView isEqual:self.pVt_search]) {
        return self.pArr_search.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.pVt_src]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SRCCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SRCCell"];
        }
        
        NSArray *rowsInSection = [_sectionsArray objectAtIndex:indexPath.section];
        O_list_item *item = [rowsInSection objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        return cell;
    }
    else if ([tableView isEqual:self.pVt_search]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SEARCHCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SEARCHCell"];
        }
        
        if (self.pArr_search.count > indexPath.row) {
            O_list_item *item = self.pArr_search[indexPath.row];
            cell.textLabel.text = item.title;
        }
        
        return cell;
    }
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.pVt_src]) {
        NSArray *rowsInSection = [_sectionsArray objectAtIndex:section];
        if (rowsInSection.count) {
            return [[_collation sectionTitles] objectAtIndex:section];
        }
        else {
            return nil;
        }
    }
    else if ([tableView isEqual:self.pVt_search]) {
        return nil;
    }
    else {
        return nil;
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.pVt_src]) {
        return [_collation sectionIndexTitles];
    }
    else if ([tableView isEqual:self.pVt_search]) {
        return nil;
    }
    else {
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if ([tableView isEqual:self.pVt_src]) {
        return [_collation sectionForSectionIndexTitleAtIndex:index];
    }
    else if ([tableView isEqual:self.pVt_search]) {
        return 0;
    }
    else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.item_selected = nil;
    O_list_item *item = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.pVt_src]) {
        NSArray *rowsInSection = [_sectionsArray objectAtIndex:indexPath.section];
        item = [rowsInSection objectAtIndex:indexPath.row];
    }
    else if ([tableView isEqual:self.pVt_search]) {
        if (self.pArr_search.count > indexPath.row) {
            item = self.pArr_search[indexPath.row];
        }
    }
    
    self.item_selected = item;
    
    NSLog(@"selected item %@", item.title);
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - action

- (void)pBtn_cancel_clicked:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pBtn_done_clicked:(id)sender
{
    
}



@end
