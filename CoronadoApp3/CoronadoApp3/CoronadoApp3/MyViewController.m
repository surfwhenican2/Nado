/*
     File: MyViewController.m
 Abstract: The main view controller of this app.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "MyViewController.h"
#import "JSON.h"

@implementation MyViewController

@synthesize scrollView1, scrollView2;
/*
const CGFloat kScrollObjHeight	= 199.0;
const CGFloat kScrollObjWidth	= 280.0;
const NSUInteger kNumImages		= 5;
*/

const CGFloat kScrollObjHeight	= 150;
const CGFloat kScrollObjWidth	= 210;
const NSUInteger kNumImages		= 5;


- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView1 subviews];

	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (kScrollObjWidth)+50;
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView1 setContentSize:CGSizeMake((20 * kScrollObjWidth), [scrollView1 bounds].size.height)];
}

- (void)viewDidLoad
{
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.theseanobrien.com/app/json2.php"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *results = [json_string JSONValue];
    
    NSArray *items = [results objectForKey:@"json"];
    NSEnumerator *enumerator = [items objectEnumerator];
    int itemscount = [items count];

    NSDictionary* item;
    NSMutableArray *fullimagepath = [[NSMutableArray alloc] init];
    NSMutableArray *thumbimagepath = [[NSMutableArray alloc] init];
    
    [json_string release];
    
    while (item = (NSDictionary*)[enumerator nextObject]) {
        NSString* fullpath = (NSString*)[item objectForKey:@"fullimagepath"];
        [fullimagepath addObject:fullpath];
        NSString* thumbpath = (NSString*)[item objectForKey:@"thumbimagepath"];
        [thumbimagepath addObject:thumbpath];
        NSLog(@"Title= %@", [item objectForKey:@"title"]);
        NSLog(@"Description= %@", [item objectForKey:@"description"]);
        NSLog(@"Imagepath= %@", [item objectForKey:@"fullimagepath"]);
    }
    
    int totalfullimages = [fullimagepath count];
    int totalthumbimages = [thumbimagepath count];
    
    NSLog(@"total items: %d:", itemscount);
    NSLog(@"total imagepaths: %d", totalfullimages);
    NSLog(@"total thumbimages: %d", totalthumbimages);
    
    
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];

	// 1. setup the scrollview for multiple images and add it to the view controller
	//
	// note: the following can be done in Interface Builder, but we show this in code for clarity
	//[scrollView1 setBackgroundColor:[UIColor blackColor]];
	[scrollView1 setCanCancelContentTouches:NO];
	scrollView1.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView1.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1.scrollEnabled = YES;
	
	// pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
	// if you want free-flowing scroll, don't set this property.
	scrollView1.pagingEnabled = YES;
	
	// load all the images from our bundle and add them to the scroll view

    NSMutableData *dataSet = [[NSMutableArray alloc] init];
    
    NSUInteger y;
	for (y = 0; y <= totalthumbimages-1; y++)
	{
        NSString *finalURL = [thumbimagepath objectAtIndex:y];
        NSURL *url = [NSURL URLWithString:finalURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        NSError *err = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        [dataSet addObject:data];
 
    }
    
	NSUInteger i;
	for (i = 1; i <= totalthumbimages; i++)
	{
		NSData *thumbdata  = [dataSet objectAtIndex:i-1];
        UIImage *thumbimage = [UIImage imageWithData:thumbdata];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbimage];
		
		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
		CGRect rect = imageView.frame;
		rect.size.height = kScrollObjHeight;
		rect.size.width = kScrollObjWidth;
		imageView.frame = rect;
		imageView.tag = i;	// tag our images for later use when we place them in serial fashion
		[scrollView1 addSubview:imageView];
        [imageView release];
        
	}
    
	[self layoutScrollImages];	// now place the photos in serial layout within the scrollview
	
    
    [dataSet release];
    
    NSString *finalURL = [fullimagepath objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:finalURL];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:url];
    NSURLResponse *response2 = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&response2 error:&err];
    UIImage *image = [UIImage imageWithData:data];
    
	[scrollView2 setCanCancelContentTouches:NO];
	scrollView2.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	scrollView2.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [scrollView2 addSubview:imageView];
	[scrollView2 setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
	[scrollView2 setScrollEnabled:YES];
	[imageView release];
    
    [thumbimagepath release];
    [fullimagepath release];
}


- (void)dealloc
{	

	[scrollView1 release];
	[scrollView2 release];
   
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// invoke super's implementation to do the Right Thing, but also release the input controller since we can do that	
	// In practice this is unlikely to be used in this application, and it would be of little benefit,
	// but the principle is the important thing.
	//
	[super didReceiveMemoryWarning];
}

@end

