//
//  ViewController.m
//  rss_reader_tut.by
//
//  Created by Radzivon Uhrynovich on 25.07.2018.
//  Copyright © 2018 Radzivon Uhrynovich. All rights reserved.
//

#import "ChannelsViewController.h"
#import "ArticlesViewController.h"
#import "Channel.h"
#import "FirstCell.h"
#import "HTMLParser.h"

static NSString *const kCellId = @"myCell";


@interface ChannelsViewController ()
@property(strong, nonatomic) NSMutableArray *headers;
@property(strong, nonatomic) NSMutableArray *channels;
@property(strong, nonatomic) NSMutableArray *freshNewsForAllArticles;
@property(strong, nonatomic) HTMLParser *parser;

@property(strong, nonatomic) NSURL *destinationURL;
//@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) UITableView *myTable;

@end

@implementation ChannelsViewController

- (NSMutableArray*)headers {
    if(_headers != nil) {
        return _headers;
    }
    _headers = [NSMutableArray array];
    return _headers;
}

- (NSMutableArray*)channels {
    if(_channels != nil) {
        return _channels;
    }
    _channels = [NSMutableArray array];
    return _channels;
}

- (NSMutableArray*)freshNewsForAllArticles {
    if(_freshNewsForAllArticles != nil) {
        return _freshNewsForAllArticles;
    }
    _freshNewsForAllArticles = [NSMutableArray array];
    return _freshNewsForAllArticles;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.parser = [[HTMLParser alloc] init];
    [self executeGetQuery: @"https://news.tut.by/rss.html"];
    
    self.myTable = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.myTable setDelegate:self];
    [self.myTable setDataSource:self];
    [self.myTable registerClass:[FirstCell class] forCellReuseIdentifier:kCellId];
    [self.view addSubview:self.myTable];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.channels[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FirstCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    Channel *channel = [[self.channels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell configureCellWithTitleText:channel.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Channel *channel = [self.channels objectAtIndex:indexPath.row];
    NSLog(@"%@", channel);
    if(channel.url != nil) {
         NSString *stringUrl = channel.url;
    }
    ArticlesViewController *articleVC = [[ArticlesViewController alloc] init];
//    if(stringUrl != nil) {
//    [articleVC setStringUrl:stringUrl];
//    }
    [self.navigationController pushViewController:articleVC animated:YES];
}


- (void) executeGetQuery:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask1 = [session downloadTaskWithRequest:request];
    [downloadTask1 resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *resStr = [self copyItem:location];
    NSDictionary *channelsAndHeaders = [self.parser parseHTML:resStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headers = [channelsAndHeaders valueForKey:kHeaders];
        self.channels = [channelsAndHeaders valueForKey:kChannels];
        self.freshNewsForAllArticles = [channelsAndHeaders valueForKey:kFreshNews];
        [self.myTable reloadData];
    });
}



- (NSString *)copyItem:(NSURL *)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [urls objectAtIndex:0];
    NSURL *originalUrl = [NSURL URLWithString:[location lastPathComponent]];
    NSURL *destinationUrl = [documentsDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    
    NSError *err;
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&err];
    [self printError:err withDescr:@"Failed to copy item"];
    NSLog(@"%@", location);
    NSLog(@"%@", destinationUrl);
    NSData *data = [[NSData alloc] initWithContentsOfURL:destinationUrl];
    NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    
    NSError *removeErr;
    [fileManager removeItemAtURL:destinationUrl error:&removeErr];
    [self printError:removeErr withDescr:@"Failed to remove item"];
    
    return resStr;
}

- (void)printError:(NSError*)error withDescr:(NSString *)desc {
    if(error != nil) {
        NSLog(@"%@\n%@\n%@", desc, error, [error localizedDescription]);
        
    } else {NSLog(@"Success");}
}



@end