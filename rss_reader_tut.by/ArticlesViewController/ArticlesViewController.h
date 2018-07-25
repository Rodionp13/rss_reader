//
//  ArticlesViewController.h
//  rss_reader_tut.by
//
//  Created by Radzivon Uhrynovich on 25.07.2018.
//  Copyright © 2018 Radzivon Uhrynovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelsViewController.h"

@interface ArticlesViewController : UIViewController <UITableViewDataSource>
@property(strong, nonatomic) NSString *stringUrl;
@end