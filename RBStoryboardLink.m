//
// RBStoryboardLink.m
//
// Copyright (c) 2012-2014 Robert Brown
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RBStoryboardLink.h"


@interface RBStoryboardLink ()

@property (nonatomic, strong, readwrite) UIViewController * scene;

@end


@implementation RBStoryboardLink

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSAssert([self.storyboardName length], @"No storyboard name");
    
    UIStoryboard * storyboard;
    NSString *storyboardName = self.storyboardName;
    // Cry device specific story board files.
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
        storyboardName = [self.storyboardName stringByAppendingString:@"_iPad"];
    else
        storyboardName = [self.storyboardName stringByAppendingString:@"_iPhone"];
    if ([[NSBundle.mainBundle pathForResource:storyboardName ofType:@"storyboardc"] length])
        storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:self.storyboardName bundle:nil];

    UIViewController * scene = nil;
    
    // Creates the linked scene.
    if ([self.sceneIdentifier length] == 0)
        scene = [storyboard instantiateInitialViewController];
    else
        scene = [storyboard instantiateViewControllerWithIdentifier:self.sceneIdentifier];
    
    NSAssert(scene,
             @"No scene found in storyboard: \"%@\" with optional identifier: \"%@\"",
             self.storyboardName,
             self.sceneIdentifier);
    
    self.scene = scene;
    
    // Grabs the UINavigationItem stuff.
    UINavigationItem * navItem = self.navigationItem;
    UINavigationItem * linkedNavItem = scene.navigationItem;
    navItem.title = linkedNavItem.title;
    navItem.titleView = linkedNavItem.titleView;
    navItem.prompt = linkedNavItem.prompt;
    navItem.hidesBackButton = linkedNavItem.hidesBackButton;
    navItem.backBarButtonItem = linkedNavItem.backBarButtonItem;
    navItem.rightBarButtonItem = linkedNavItem.rightBarButtonItem;
    navItem.rightBarButtonItems = linkedNavItem.rightBarButtonItems;
    navItem.leftBarButtonItem = linkedNavItem.leftBarButtonItem;
    navItem.leftBarButtonItems = linkedNavItem.leftBarButtonItems;
    navItem.leftItemsSupplementBackButton = linkedNavItem.leftItemsSupplementBackButton;
    
    // Grabs the UITabBarItem
    // The link overrides the contained view's tab bar item.
    if (self.tabBarController)
        scene.tabBarItem = self.tabBarItem;
    
    // Grabs the edit button.
    UIBarButtonItem * editButton = self.editButtonItem;
    UIBarButtonItem * linkedEditButton = scene.editButtonItem;
    
    if (linkedEditButton) {
        editButton.enabled = linkedEditButton.enabled;
        editButton.image = linkedEditButton.image;
        editButton.landscapeImagePhone = linkedEditButton.landscapeImagePhone;
        editButton.imageInsets = linkedEditButton.imageInsets;
        editButton.landscapeImagePhoneInsets = linkedEditButton.landscapeImagePhoneInsets;
        editButton.title = linkedEditButton.title;
        editButton.tag = linkedEditButton.tag;
        editButton.target = linkedEditButton.target;
        editButton.action = linkedEditButton.action;
        editButton.style = linkedEditButton.style;
        editButton.possibleTitles = linkedEditButton.possibleTitles;
        editButton.width = linkedEditButton.width;
        editButton.customView = linkedEditButton.customView;
        editButton.tintColor = linkedEditButton.tintColor;
    }
    
    // Grabs the modal properties.
    self.modalTransitionStyle = scene.modalTransitionStyle;
    self.modalPresentationStyle = scene.modalPresentationStyle;
    self.definesPresentationContext = scene.definesPresentationContext;
    self.providesPresentationContextTransitionStyle = scene.providesPresentationContextTransitionStyle;
    
    // Grabs the popover properties.
	if ([self respondsToSelector: @selector(preferredContentSize)])
		self.preferredContentSize = scene.preferredContentSize;
	else
		self.contentSizeForViewInPopover = scene.contentSizeForViewInPopover;
    self.modalInPopover = scene.modalInPopover;
    
    // Grabs miscellaneous properties.
    self.title = scene.title;
    self.hidesBottomBarWhenPushed = scene.hidesBottomBarWhenPushed;
    self.editing = scene.editing;
    
    // Translucent bar properties.
	if ([self respondsToSelector: @selector(automaticallyAdjustsScrollViewInsets)]) {
		self.automaticallyAdjustsScrollViewInsets = scene.automaticallyAdjustsScrollViewInsets;
		self.edgesForExtendedLayout = scene.edgesForExtendedLayout;
		self.extendedLayoutIncludesOpaqueBars = scene.extendedLayoutIncludesOpaqueBars;
		self.modalPresentationCapturesStatusBarAppearance = scene.modalPresentationCapturesStatusBarAppearance;
		self.transitioningDelegate = scene.transitioningDelegate;
	} else
		self.wantsFullScreenLayout = scene.wantsFullScreenLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Adds the view controller as a child view.
    UIViewController * scene = self.scene;
    [self addChildViewController:scene];
    [self.view addSubview:scene.view];
    [self.scene didMoveToParentViewController:self];
    
	if ([scene.view respondsToSelector: @selector(translatesAutoresizingMaskIntoConstraints)]) {
		scene.view.translatesAutoresizingMaskIntoConstraints = NO;
		
		NSDictionary * views = @{
								 @"topGuide"    : self.topLayoutGuide,
								 @"bottomGuide" : self.bottomLayoutGuide,
								 @"view"        : scene.view,
								 };
		
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
																		  options:0
																		  metrics:nil
																			views:views]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][view][bottomGuide]"
																		  options:0
																		  metrics:nil
																			views:views]];
	} else {
		// Adjusts the frame of the child view.
		CGRect frame = self.view.frame;
		CGRect linkedFrame = scene.view.frame;
		linkedFrame.origin.x -= frame.origin.x;
		linkedFrame.origin.y -= frame.origin.y;

		// The scene's main view must be made flexible so it will resize properly
		// in the container.
		scene.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
									   UIViewAutoresizingFlexibleHeight);

		scene.view.frame = linkedFrame;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.scene isKindOfClass:[UINavigationController class]] || [self.scene isKindOfClass:[UITabBarController class]])
        [self.scene viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.scene isKindOfClass:[UINavigationController class]] || [self.scene isKindOfClass:[UITabBarController class]])
        [self.scene viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.scene isKindOfClass:[UINavigationController class]] || [self.scene isKindOfClass:[UITabBarController class]])
        [self.scene viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.scene isKindOfClass:[UINavigationController class]] || [self.scene isKindOfClass:[UITabBarController class]])
        [self.scene viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    // The linked scene defines the rotation.
    return [self.scene shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate {
    
    // The linked scene defines autorotate.
    return [self.scene shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    
    // The linked scene defines supported orientations.
    return [self.scene supportedInterfaceOrientations];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.scene;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.scene;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.scene preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden {
    return [self.scene prefersStatusBarHidden];
}


#pragma mark - Message forwarding

// The following methods are important to get unwind segues to work properly.

- (BOOL)respondsToSelector:(SEL)aSelector {
    return ([super respondsToSelector:aSelector] ||
            [self.scene respondsToSelector:aSelector]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return ([super methodSignatureForSelector:aSelector]
            ?:
            [self.scene methodSignatureForSelector:aSelector]);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    if ([self.scene respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.scene];
    else
        [super forwardInvocation:anInvocation];
}

@end
