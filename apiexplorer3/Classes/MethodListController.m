#import "MethodListController.h"
#import <objc/runtime.h>



@interface WebViewController : UIViewController {
	UIWebView *webView; 
	NSString *codeurl;
}

@property (nonatomic, retain) UIWebView *webView;

-(void) loadCode: (NSString *)url;

@end

@implementation WebViewController

@synthesize webView;



-(void)loadView
{	
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	[contentView release];
	
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.x = webFrame.origin.y = 0;
	webView = [[UIWebView alloc] initWithFrame:webFrame];
	webView.backgroundColor = [UIColor whiteColor];
	webView.contentMode = UIViewContentModeTop;
	webView.scalesPageToFit = YES;
	webView.autoresizesSubviews = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.delegate = nil;

	[self.view addSubview:webView];
}


- (void)dealloc {
	[webView release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
//	NSLog(@"codeurl is %@",codeurl);
#ifdef OS3
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://ericasadun.com/iPhoneDocs312/" stringByAppendingString:codeurl] ]]];
#else
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://ericasadun.com/iPhoneDocs220/" stringByAppendingString:codeurl] ]]];
#endif

//	[webView reload];
}

- (void)viewWillDisappear:(BOOL)animated {
//	NSLog(@"stop loading codeurl is %@",codeurl);
	[webView stopLoading];
}

-(void) loadCode:(NSString *)url {
	if (url)
		codeurl = url;
	else
		codeurl = @"";
}

@end



@implementation MethodListController

@synthesize instanceMethods;
@synthesize classMethods;
@synthesize ivars;
@synthesize protocols;
@synthesize cls;
@synthesize tview;
@synthesize wv;

enum sections {
	s_superclass,
	s_protocols,
	s_ivars,
	s_cmeths,
	s_imeths
};
/*
- (NSString *)title {
	return cls;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSString *)superclassName {
	return [[theCls superclass] description];
}

- (id)initWithClassNamed:(NSString *)name {
//	self = [self initWithNibName:@"MethodListController" bundle:nil];
	
//	self = [self init];
//	NSLog(@"MethodListController,initWithClassNamed");
	if (self = [self init]) {	
		[self setCls:name];
	}
	return self;
}

-(void)loadView
{	
//	NSLog(@"MethodListController,loadView");
	// setup our parent content view and embed it this view controller
	// having a generic contentView (as opposed to UITableView taking up the entire view controller)
	// makes your UI design more flexible as you can add more subviews later
	//
#ifdef OS3
	NSString *codeplist = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"code312.plist"];
#else
	NSString *codeplist = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"code.plist"];
#endif
	codedict = [[NSDictionary alloc] initWithContentsOfFile:codeplist];
	wv = [[WebViewController alloc] init];
	
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
	[contentView release];

	// finally create a our table, its contents will be populated by "menuList" using the UITableView delegate methods
	tview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	tview.delegate = self;
	tview.dataSource = self;
	tview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	// setup our list view to autoresizing in case we decide to support autorotation along the other UViewControllers
	tview.autoresizesSubviews = YES;
	tview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[tview reloadData];	// populate our table's data
	[self.view addSubview: tview];
	self.view.autoresizesSubviews = YES;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reference"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(codeView)];
	
#ifdef v1
	if([theCls instancesRespondToSelector:@selector(initWithFrame:)])
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Draw"
																				  style:UIBarButtonItemStylePlain
																				 target:self
																				 action:@selector(drawView)];
#endif
	

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case s_superclass:
			return [self superclassName] != nil;
		case s_protocols:
			return protocols.count;
		case s_ivars:
			return ivars.count;
		case s_cmeths:
			return classMethods.count;
		case s_imeths:
			return instanceMethods.count;
		default:
			return NSIntegerMax;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case s_superclass:
			return @"Superclass";
		case s_protocols:
			return @"Implemented protocols";
		case s_ivars:
			return @"Instance variables";
		case s_cmeths:
			return @"Class methods";
		case s_imeths:
			return @"Instance methods";
		default:
			return @"";
	}
}

// decide what kind of accesory view (to the far right) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case s_superclass:
			return UITableViewCellAccessoryDisclosureIndicator;
		default:
			return UITableViewCellAccessoryNone;
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	NSArray *array = nil;
	
	switch (indexPath.section) {
		case s_superclass:
			array = [NSArray arrayWithObject:[self superclassName]];
			break;
		case s_protocols:
			array = protocols; break;
		case s_ivars:
			array = ivars; break;
		case s_cmeths:
			array = classMethods; break;
		case s_imeths:
			array = instanceMethods; break;
	}
	if(!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	
	if ( [cell respondsToSelector:@selector(setText:)] ) {
		[cell setText:[array objectAtIndex:indexPath.row]];
	}
	else {
		cell.textLabel.text =[array objectAtIndex:indexPath.row];
	}
	
	return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	if([tview indexPathForSelectedRow]) {
		[tview deselectRowAtIndexPath:[tview indexPathForSelectedRow] animated:YES];
	}

	if ([codedict valueForKey:self.title])
		self.navigationItem.rightBarButtonItem.enabled = YES;
	else
		self.navigationItem.rightBarButtonItem.enabled = NO;
}

#ifdef v1
- (void)drawView {  
	ThingerController *tc = [[ThingerController alloc] initWithNibName:@"ViewThinger" bundle:nil];
	@try {
		[tc setTheView:[[theCls alloc] initWithFrame:CGRectMake(20, 100, 50, 50)]];
		[self.navigationController pushViewController:tc animated:YES];
	} @catch (NSException *e) {
		[[UIAlertView alloc] initWithTitle:@"Drawing Error"
								   message:[e description]
								  delegate:self
                         cancelButtonTitle:@"Back"
                         otherButtonTitles:nil];
	}
	[tc release];
}
#endif

- (void)codeView {  
//	NSLog(@"loading webview for title %@",self.title);
	[wv loadCode: [codedict valueForKey:self.title]];
	[self.navigationController pushViewController:wv animated:YES];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == s_superclass ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"MethodListController,didSelectRowAtIndexPath");
	if(indexPath.section == s_superclass) {
		MethodListController *mlc = [[MethodListController alloc] initWithClassNamed:[self superclassName]];                                
		[self.navigationController pushViewController:mlc animated:YES];    
		[mlc release];
	}
}

- (void)setCls:(NSString *)c {
	cls = [c retain];
	theCls = objc_getClass([cls UTF8String]);
	
	unsigned int iMethods, cMethods;
	
	Method *iMethList = class_copyMethodList(theCls, &iMethods);
	Method *cMethList = class_copyMethodList(object_getClass(theCls), &cMethods);
	
	instanceMethods = [NSMutableArray new];
	for (int i = 0; i < iMethods; i++) {
		[instanceMethods addObject:[NSString stringWithCString:sel_getName(method_getName(iMethList[i]))]];
	}
	[instanceMethods sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	free(iMethList);
	
	classMethods = [NSMutableArray new];
	for (int i = 0; i < cMethods; i++) {
		[classMethods addObject:[NSString stringWithCString:sel_getName(method_getName(cMethList[i]))]];
	}
	[classMethods sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	free(cMethList);
	
	unsigned int protCount;
	Protocol **protLst = class_copyProtocolList(theCls, &protCount);
	protocols = [NSMutableArray new];  
	for(int i = 0; i < protCount; i++) {
		[protocols addObject:[NSString stringWithCString:protocol_getName(protLst[i])]];
	}  
	free(protLst);
	
	ivars = [NSMutableArray new];
	unsigned int ivarCount;
	Ivar *ivarLst = class_copyIvarList(theCls, &ivarCount);
	for(int i = 0; i < ivarCount; i++) {
		[ivars addObject:[NSString stringWithCString:ivar_getName(ivarLst[i])]];
	}  
	free(ivarLst);
	self.title = cls;
	[tview reloadData];	// populate our table's data
}

- (void)dealloc {
	[instanceMethods dealloc];
	[classMethods dealloc];
	[ivars dealloc];
	[codedict dealloc];
	[wv release];
	[tview release];
	[cls release];
	[super dealloc];
}

@end
