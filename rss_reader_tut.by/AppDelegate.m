//
//  AppDelegate.m
//  rss_reader_tut.by
//
//  Created by Radzivon Uhrynovich on 25.07.2018.
//  Copyright © 2018 Radzivon Uhrynovich. All rights reserved.
//

#import "AppDelegate.h"
#import "ChannelsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:UIColor.whiteColor];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[ChannelsViewController alloc] init]];
    [self.window setRootViewController:nc];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Default Session

+ (void)downloadTaskWith:(NSURL *)url handler:(void(^)(NSURL *destinationUrl))complition {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *urlS = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentDir = [urlS objectAtIndex:0];
        NSURL *originalUrl = [NSURL URLWithString:[location lastPathComponent]];
        NSURL *destinationUrl = [documentDir URLByAppendingPathComponent:[originalUrl lastPathComponent]];
        NSLog(@"destinationUrl\n %@", destinationUrl);
        [fm copyItemAtURL:location toURL:destinationUrl error:nil];
        
        complition(destinationUrl);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"OKAY frrom download ASUNC_GET_MAIN - can reload Data here");
        });
    }];
    [downloadTask resume];
}

+ (NSURL *)copyItem:(NSURL *)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [urls objectAtIndex:0];
    NSURL *originalUrl = [NSURL URLWithString:[location lastPathComponent]];
    NSURL *destinationUrl = [documentsDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    
    NSError *err;
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&err];
    [AppDelegate printError:err withDescr:@"Failed to copy item"];
    NSLog(@"%@", location);
    NSLog(@"%@", destinationUrl);
//    NSData *data = [[NSData alloc] initWithContentsOfURL:destinationUrl];
//    NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    
//    NSError *removeErr;
//    [fileManager removeItemAtURL:destinationUrl error:&removeErr];
//    [AppDelegate printError:removeErr withDescr:@"Failed to remove item"];
    
    return destinationUrl;
}

+ (void)printError:(NSError*)error withDescr:(NSString *)descr {
    if(error != nil) {
        NSLog(@"%@\n%@\n%@", descr, error, [error localizedDescription]);
    } else {NSLog(@"Success");}
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"rss_reader_tut_by"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
