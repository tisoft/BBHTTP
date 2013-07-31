//
// Copyright 2013 BiasedBit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

//
//  Created by Bruno de Carvalho - @biasedbit / http://biasedbit.com
//  Copyright (c) 2013 BiasedBit. All rights reserved.
//

#import "AppDelegate.h"

#import "BBHTTP.h"



#pragma mark -

@implementation AppDelegate


#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
//    [self getImageExample];
//    [self getJsonExample];
//    [self getExample];
//    [self postExample];
    [self testRedirect];
    
    
    return YES;
}

- (void)getImageExample
{
    [[BBHTTPRequest readResource:@"http://biasedbit.com/images/badge_dark.png"] setup:^(id request) {
        [request downloadContentAsImage]; // alternative to 'asImage' fluent syntax
    } execute:^(BBHTTPResponse* response) {
        UIImage* image = response.content;
        NSLog(@"image size: %@", NSStringFromCGSize(image.size));
    } error:^(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (void)getJsonExample
{
    NSString* yahooWeather = @"http://query.yahooapis.com/v1/public/yql?format=json&q="
    "select%20*%20from%20weather.forecast%20where%20woeid%3D2502265";

    [[[BBHTTPRequest readResource:yahooWeather] asJSON] execute:^(BBHTTPResponse* response) {
        NSLog(@"%@: %@",
              response.content[@"query.results.channel.description"],
              response.content[@"query.results.channel.item.condition.text"]);
        //        DOBJ(response.content); // dump the whole JSON response

    } error:^(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (void)getExample
{
    [[BBHTTPRequest readResource:@"http://biasedbit.com"] execute:^(BBHTTPResponse* response) {
        NSLog(@"Finished: %u %@ -- received %u bytes of '%@' %@",
              response.code, response.message, response.contentSize,
              response[@"Content-Type"], response.headers);

    } error:^(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (void)postExample
{
    BBHTTPRequest* upload = [BBHTTPRequest createResource:@"http://target.api/" withContentsOfFile:@"/path/to/file"];
    upload.uploadProgressBlock = ^(NSUInteger current, NSUInteger total) {
        NSLog(@"--> %u/%u", current, total);
    };
    upload.downloadProgressBlock = ^(NSUInteger current, NSUInteger total) {
        NSLog(@"<== %u/%u%@", current, total, total == 0 ? @" (chunked download, total size unknown)" : @"");
    };

    [upload setup:^(BBHTTPRequest* request) {
        request[@"User-Agent"] = @"<3 subscript operators";
    } execute:^(BBHTTPResponse* response) {
        NSLog(@"%@ %u %@ %@", NSStringFromBBHTTPProtocolVersion(response.version),
              response.code, response.message, response.headers);
    } error:^(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (void)testRedirect
{
    [BBHTTPExecutor sharedExecutor].verbose=YES;
    
    BBHTTPRequest* redirect=[BBHTTPRequest readResource:@"http://pass.telekom.de"];

redirect[@"User-Agent"]=@"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";
                             
    [redirect setMaxRedirects:-1];
    
    [redirect execute:^(BBHTTPResponse* response) {
        NSLog(@"Finished: %u %@ -- received %u bytes of '%@' %@",
              response.code, response.message, response.contentSize,
              response[@"Content-Type"], response.headers);
        NSLog(@"Content: %@", [[NSString alloc] initWithData:response.content
                                                    encoding:NSUTF8StringEncoding]);
        
    } error:^(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
 
}


@end
