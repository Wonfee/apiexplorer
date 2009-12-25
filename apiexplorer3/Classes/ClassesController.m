#import "ClassesController.h"
#import "ExplorerAppDelegate.h"
#import <objc/objc.h>
#import <objc/runtime.h>

const int kMaxClasses = 10000;
NSMutableArray *objCClasses;
NSMutableArray *fullObjCClasses;
int objCClassesNum;

@implementation ClassesController

@synthesize classSearchBar;
@synthesize mlc;


+ (void)initialize {
	Class *clsList = malloc(sizeof(Class) * kMaxClasses);
	
	if(!clsList) {
		NSLog(@"Couldn't allocate space for %d classes", kMaxClasses);
		exit(1);
	}
	
	int numClasses = objc_getClassList(clsList, kMaxClasses);
	int i;
	
	objCClasses = [NSMutableArray arrayWithCapacity:27];
	fullObjCClasses = [NSMutableArray new];
	objCClassesNum = numClasses;
	objCClassesNum = 0;
	[objCClasses addObject:[NSMutableArray new]];  
	for(i = 0; i <= 26; i++) {
		[objCClasses addObject:[NSMutableArray new]];
	}
	
	for(i = 0; i < numClasses; i++) {
		const char *name = class_getName(clsList[i]);
		NSString *str = [NSString stringWithCString:name];
		if (![str isEqualToString:@"MethodListController"] && ![str isEqualToString:@"ClassesController"]  && ![str isEqualToString:@"ExplorerAppDelegate"] ) { 
			[fullObjCClasses addObject:str];
			if(name[0] >= 'A' && name[0] <= 'Z')
				[[objCClasses objectAtIndex:((name[0] - 'A') + 0)] addObject:str];
			else
				[[objCClasses objectAtIndex:26] addObject:str];
			objCClassesNum++;
		}
	}
	
	NSMutableArray *sorted = [NSMutableArray new];
	NSMutableArray *subArray;
	for(subArray in objCClasses) {
		[sorted addObject:[subArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	}
	
	free(clsList);
	
	objCClasses = sorted;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[objCClasses objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return objCClasses.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K",
			@"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
			@"X", @"Y", @"Z", @"*", nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	
	if ( [cell respondsToSelector:@selector(setText:)] ) {
		[cell setText:[[objCClasses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	}
	else {
		cell.textLabel.text =[[objCClasses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *clsName = [[objCClasses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[mlc setCls:clsName];
	[self.navigationController pushViewController:mlc animated:YES];
}

- (void)awakeFromNib {
	self.title = @"Classes";
}

#ifdef OK
- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Classes";	
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
//	self.navigationItem.rightBarButtonItem = nil;
//	self.navigationItem.leftBarButtonItem = nil;
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem.width = 0;
	
	self.navigationItem.titleView = classSearchBar;
	self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);
}

#endif

-(void)loadView
{
	self.title = @"Classes";
	[super loadView];
	mlc = [[MethodListController alloc] init];
	classSearchBar = [[UISearchBar alloc] init];
//	classSearchBar.showsCancelButton = YES;
	classSearchBar.frame = CGRectMake(0, 0, 320, 44);
	self.navigationItem.titleView = classSearchBar;
	self.navigationItem.titleView.frame = CGRectMake(0, 0, 240, 44);
#ifdef OS3
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:1]).enablesReturnKeyAutomatically = NO;
	// This line of code adds the ability to control the return button pressed functionality. UISearchBar does not extend UITextView and instead contains a UITextView inside of it. 
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:1]).returnKeyType = UIReturnKeyDone;
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:1]).delegate = self;
	// This line of code sets up the on text changed event that is used to filter the main data provider mutable array 
#else
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:0]).enablesReturnKeyAutomatically = NO;
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:0]).returnKeyType = UIReturnKeyDone;
	((UITextField *)[(NSArray *)[classSearchBar subviews] objectAtIndex:0]).delegate = self;
#endif
	
	classSearchBar.delegate = self;
	//	[searchBar release];
	
}


//click Search on UIKeyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// Minimizes UIKeyboard on screen 
	[textField resignFirstResponder];
	return YES;
}

// Called after the text in the field changes. 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[objCClasses release];
	objCClasses = [NSMutableArray arrayWithCapacity:27];
	[objCClasses addObject:[NSMutableArray new]];
	int i;
	for(i = 0; i <= 26; i++) {
		[objCClasses addObject:[NSMutableArray new]];
	}
		
	// Tests if the UISearchBar is not empty
	if([searchBar.text localizedCaseInsensitiveCompare:@""] != NSOrderedSame){
		
		for(i = 0; i < objCClassesNum; i++) {
			NSRange range =[(NSString *)[fullObjCClasses objectAtIndex:i] rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
			if(range.location != NSNotFound){
				NSString *str = [fullObjCClasses objectAtIndex:i];
				char cstr = [str characterAtIndex:0]; 
				if(cstr >= 'A' && cstr <= 'Z')
					[[objCClasses objectAtIndex:((cstr - 'A') + 0)] addObject:str];
				else
					[[objCClasses objectAtIndex:26] addObject:str];				
			}			
		}
	}
	else {
		for(i = 0; i < objCClassesNum; i++) {
			NSString *str = [fullObjCClasses objectAtIndex:i];
			char cstr = [str characterAtIndex:0]; 
			if(cstr >= 'A' && cstr <= 'Z')
				[[objCClasses objectAtIndex:((cstr - 'A') + 0)] addObject:str];
			else
				[[objCClasses objectAtIndex:26] addObject:str];
		}
	}
	NSMutableArray *sorted = [NSMutableArray new];
	NSMutableArray *subArray;
	for(subArray in objCClasses) {
		[sorted addObject:[subArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	}
	objCClasses = sorted;	

	// Called to refresh the table view with changed data provider. 
	[self.tableView reloadData];
}

- (void)dealloc {
	[objCClasses dealloc];
	[fullObjCClasses dealloc];
	[classSearchBar release];
	[mlc release];
	[super dealloc];
}


@end

