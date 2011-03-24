//
//  CCPhoto.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/7/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCPhoto.h"
#import "Cocoafish.h"
#import "CCDownloadManager.h"

@interface CCPhoto ()

@property (nonatomic, retain, readwrite) NSString *filename;
@property (nonatomic, readwrite) int size;
@property (nonatomic, retain, readwrite) NSString *collectionName;
@property (nonatomic, retain, readwrite) NSString *md5;
@property (nonatomic, readwrite) BOOL processed;
@property (nonatomic, retain, readwrite) NSString *contentType;
@property (nonatomic, retain, readwrite) NSDictionary *urls;
@property (nonatomic, retain, readwrite) NSDate *takenAt;

@end

@implementation CCPhoto
@synthesize filename = _filename;
@synthesize size = _size;
@synthesize collectionName = _collectionName;
@synthesize md5 = _md5;
@synthesize processed = _processed;
@synthesize contentType = _contentType;
@synthesize urls = _urls;
@synthesize takenAt = _takenAt;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{

	if ((self = [super initWithJsonResponse:jsonResponse])) {
		self.filename = [jsonResponse objectForKey:CC_JSON_FILENAME];
		self.size = [[jsonResponse objectForKey:CC_JSON_SIZE] intValue];
		self.collectionName = [jsonResponse objectForKey:CC_JSON_COLLECTION_NAME];
		self.md5 = [jsonResponse objectForKey:CC_JSON_MD5];
		self.processed = [[jsonResponse objectForKey:CC_JSON_PROCESSED] boolValue];
		self.contentType = [jsonResponse objectForKey:CC_JSON_CONTENT_TYPE];
		self.urls = [jsonResponse objectForKey:CC_JSON_URLS];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
		
		NSString *dateString = [jsonResponse objectForKey:CC_JSON_TAKEN_AT];
		if (dateString) {
			self.takenAt = [dateFormatter dateFromString:dateString];
		}
		
		if (self.processed == NO) {
			// Photo hasn't been processed on the server, add to the download manager queue 
			// it will pull for its status periodically.
			[[Cocoafish defaultCocoafish].downloadManager addProcessingPhoto:self];
		}
			
	}
	
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCPhoto:\n\tfilename: %@\n\tsize: %d\n\tcollectionName: %@\n\tmd5: %@\n\tprocessed: %d\n\tcontentType :%@\n\ttakenAt: %@\n\turls: %@\n\t%@",
            self.filename, self.size, self.collectionName, self.md5, 
            self.processed, self.contentType, self.takenAt, [self.urls description], [super description]];
}

-(void)dealloc
{
	self.filename = nil;
	self.collectionName = nil;
	self.md5 = nil;
	self.contentType = nil;
	self.urls = nil;
	self.takenAt = nil;
	[super dealloc];
}

-(void)updateUrls:(NSDictionary *)urls
{
	if (urls == nil) {
		return;
	}
	@synchronized(self) {
		self.urls = urls;
		self.processed = YES;
	}
}

-(NSString *)getPhotoUrl:(PhotoSize)photoSize
{
	@synchronized(self) {
		switch (photoSize) {
			case CC_SQUARE:
				return [_urls objectForKey:@"square_75"];
			case CC_THUMB:
				return [_urls objectForKey:@"thumb_100"];
			case CC_SMALL:
				return [_urls objectForKey:@"small_240"];
			case CC_MEDIUM_500:
				return [_urls objectForKey:@"medium_500"];
			case CC_MEDIUM_640:
				return [_urls objectForKey:@"medium_640"];
			case CC_LARGE:
				return [_urls objectForKey:@"large_1024"];			
			case CC_ORIGINAL:
				return [_urls objectForKey:@"original"];
			default:
				break;
		}
	}
	return nil;
			
}

-(UIImage *)getPhoto:(PhotoSize)photoSize
{
	return [UIImage imageWithContentsOfFile:[self localPath:photoSize]];
}

-(NSString *)localPath:(PhotoSize)photoSize
{
	return [NSString stringWithFormat:@"%@/%@_%d", [Cocoafish defaultCocoafish].cocoafishDir, self.objectId, photoSize];
}

-(Boolean)asyncGetPhoto:(PhotoSize)photoSize
{
	// will download in the background and send a notification later
	return [[Cocoafish defaultCocoafish].downloadManager downloadPhoto:self size:photoSize];
}

@end