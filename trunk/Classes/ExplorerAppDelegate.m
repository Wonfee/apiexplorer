#import "ExplorerAppDelegate.h"
#import "ClassesController.h"

@implementation ExplorerAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// To set the status bar as black, use the following:
	//application.statusBarStyle = UIStatusBarStyleOpaqueBlack;
	
	// create window 
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// this helps in debugging, so that you know "exactly" where your views are placed;
	// if you see "red", you are looking at the bare window, otherwise use black
	// window.backgroundColor = [UIColor redColor];
	
	window.backgroundColor = [UIColor blackColor];
    
	// set up main view navigation controller
    ClassesController *navController = [[ClassesController alloc] init];
	
	// create a navigation controller using the new controller
	navigationController = [[UINavigationController alloc] initWithRootViewController:navController];
	[navController release];

	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
  [navigationController release];
  [window release];
  [super dealloc];
}

@end
