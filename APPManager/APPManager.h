//
//  Manager.h
//  rss_reader_tut.by
//
//  Created by User on 7/30/18.
//  Copyright © 2018 Radzivon Uhrynovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APPManagerDelegate
@optional

- (void) complitionLoadingChannelsData:(NSDictionary *)channelsData;
@end

//@protocol APPManagerCoreDateDelegate
//
//- (NSDictionary *) parseMOinToObjects:(NSArray *)managedObjects;
//@end

@interface APPManager : NSObject
@property(weak, nonatomic) id <APPManagerDelegate> delegate;
//@property(strong, nonatomic) id <APPManagerCoreDateDelegate> cdDelegate;

- (void)checkingForLoadingChennelContent;
@end
