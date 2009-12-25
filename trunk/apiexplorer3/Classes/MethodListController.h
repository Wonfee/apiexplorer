#import <UIKit/UIKit.h>
//#import "ThingerController.h"
@class WebViewController;

@interface MethodListController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *instanceMethods, *classMethods, *ivars, *protocols;
	NSString *cls;
	id theCls;
	UITableView *tview;
	NSDictionary *codedict;
	WebViewController  *wv;
}

@property (nonatomic, retain) NSArray *instanceMethods, *classMethods, *ivars, *protocols;
@property (nonatomic, retain) NSString *cls;
@property (nonatomic, retain) UITableView *tview;
@property (nonatomic, retain) WebViewController  *wv;

- (id)initWithClassNamed:(NSString *)name;
- (void)setCls:(NSString *)c;

@end
