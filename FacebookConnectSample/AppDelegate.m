//
//  AppDelegate.m
//  FacebookConnectSample
//
//  Created by Dan Berenholtz on 6/15/12.
//  Copyright (c) 2012 WhoWentOut. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize facebook;

- (void)dealloc
{
  [_window release];
  [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  
  // Override point for customization after application launch.
  self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  
  [self initFacebookObject];
  [self addFacebookLoginButton];
  [self addFacebookLogoutButton];
  
  return YES;
}

- (void) initFacebookObject
{
  // create a facebook instance with the given app id
  facebook = [[Facebook alloc] initWithAppId:@"183435348401103" andDelegate:self];
  // if fb login credentials are already saved away, get them from there
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"] 
      && [defaults objectForKey:@"FBExpirationDateKey"]) {
    facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
  }
}

- (void) addFacebookLoginButton
{
  // Add the logout button
  UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  loginButton.frame = CGRectMake(40, 40, 200, 40);
  
  [loginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
  [loginButton addTarget:self action:@selector(loginButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
  
  [self.viewController.view addSubview:loginButton];
}

- (void) addFacebookLogoutButton
{
  // Add the logout button
  UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  logoutButton.frame = CGRectMake(40, 120, 200, 40);
  
  [logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
  [logoutButton addTarget:self action:@selector(logoutButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
  
  [self.viewController.view addSubview:logoutButton];
}

// Method that gets called when the logout button is pressed
- (void) logoutButtonClicked 
{
  NSLog(@"logoutButtonClicked");
  [facebook logout];
}

- (BOOL) isUserLoggedIn
{
  return [facebook isSessionValid];
}

- (void) showLoginPrompt
{
  [facebook authorize:nil];
}

- (void) loginButtonClicked 
{
  NSLog(@"loginButtonClicked");
  if (![self isUserLoggedIn]) {
    [self showLoginPrompt];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
  NSLog(@"fbDidLogin");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
  
  NSLog(@"fb token = %@", [facebook accessToken]);
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
  NSLog(@"fbDidNotLogin");
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
  NSLog(@"fbDidExtendToken");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
  NSLog(@"fbDidLogout");
  // Remove saved authorization information if it exists
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"FBAccessTokenKey"]) {
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
  }
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
  NSLog(@"fbSessionInvalidated");
}


// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [facebook handleOpenURL:url]; 
}


@end
