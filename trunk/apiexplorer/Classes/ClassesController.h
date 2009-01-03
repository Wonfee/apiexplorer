#import <UIKit/UIKit.h>
#import "MethodListController.h"


@interface ClassesController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate>{
	UISearchBar *classSearchBar;
	MethodListController *mlc;
}

@property (nonatomic, retain) UISearchBar *classSearchBar;
@property (nonatomic, retain) MethodListController *mlc;

@end
