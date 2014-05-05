#import <AppKit/AppKit.h>

#import <stdlib.h>

// http://stackoverflow.com/questions/14099363/get-the-current-wallpaper-in-cocoa

void naive()
{
	NSWorkspace *w = [NSWorkspace sharedWorkspace];
	NSURL *url = [w desktopImageURLForScreen:[NSScreen mainScreen]];
	NSString *path = [url path];
	printf("%s\n", [path UTF8String]);
}

void hacky()
{
	NSDictionary *spacesPLIST = (__bridge NSDictionary *)(
		CFPreferencesCopyAppValue(CFSTR("SpacesConfiguration"),
			CFSTR("com.apple.spaces")));
	NSDictionary *desktopPLIST = (__bridge NSDictionary *)(
		CFPreferencesCopyAppValue(CFSTR("Background"),
			CFSTR("com.apple.desktop")));

	NSArray *monitors = [spacesPLIST
		valueForKeyPath:@"Management Data.Monitors"];
	NSInteger monitorIndex = 0;
	if ([monitors count] > 1) {
		//search for main (or ask user to select)
	}
	NSDictionary *monitor = [monitors objectAtIndex:monitorIndex];
	NSDictionary *spaces = [desktopPLIST valueForKey:@"spaces"];
	NSString *currentSpaceUUID = [monitor
		valueForKeyPath:@"Current Space.uuid"];
	NSDictionary *currentSpace = [spaces valueForKey:currentSpaceUUID];
	NSURL *desktopPicturesDirectory = [NSURL
		fileURLWithPath:[currentSpace valueForKeyPath:@"default.ChangePath"]
		isDirectory:true];
	NSString *desktopPictureName = [currentSpace
		valueForKeyPath:@"default.LastName"];
	NSURL *desktopPictureURL = [NSURL URLWithString:desktopPictureName
		relativeToURL:desktopPicturesDirectory];

	NSError *error = nil;
	NSString *path = [[NSFileManager defaultManager]
		destinationOfSymbolicLinkAtPath:[desktopPictureURL path] error:&error];

	if (!path)
		path = [desktopPictureURL path];
	// Inserts alias resolving of http://stackoverflow.com/a/17570232/172690
	//NSData *bookmarkData = [NSURL
	//	bookmarkDataWithContentsOfURL:desktopPictureURL error:&error];
	//NSLog(@"bookmark %@ error %@", bookmarkData, error);
	//NSDictionary *values = [NSURL resourceValuesForKeys:@[NSURLPathKey]
	//	fromBookmarkData:bookmarkData];
	//NSLog(@"values %@", values);
	//NSString *path = [values objectForKey:NSURLPathKey];
	printf("%s\n", [path UTF8String]);
	[[NSWorkspace sharedWorkspace] selectFile:path
		inFileViewerRootedAtPath:@""];
}

int main(void)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//naive();
	hacky();
	[pool release];
	return 0;
}
