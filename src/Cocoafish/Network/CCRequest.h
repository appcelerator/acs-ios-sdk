//
//  CCRequest.h
//  APIs
//
//  Created by Wei Kong on 4/2/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@class CCObject;
@class CCResponse;
@class CCUploadImage;
@class CCAttachment;
@class CCPhotoAttachment;

@protocol CCRequestDelegate;

// use format data request all the time
@interface CCRequest : ASIFormDataRequest {
    id<CCRequestDelegate> _requestDelegate;
    NSString *_requestId;
    CCAttachment *_attachment;
}

-(id)initWithDelegate:(id)requestDelegate  httpMethod:(NSString *)httpMethod baseUrl:(NSString *)baseUrl paramDict:(NSDictionary *)paramDict;
-(CCResponse *)startSynchronous;
-(void)main;
-(void)addPhoto:(CCPhotoAttachment *)photoAttachment;

@property(nonatomic, assign) id<CCRequestDelegate> requestDelegate;
@property (nonatomic, retain, readonly) NSString *requestId;
@property (nonatomic, retain, readonly) CCAttachment *attachment;
@end

// Delegate callback methods
@protocol CCRequestDelegate <NSObject>

@optional

// generic callback, if we received custom objects or above callbacks were not implemented
-(void)request:(CCRequest *)request didSucceed:(CCResponse *)response;

-(void)request:(CCRequest *)request didFailWithError:(NSError *)error;

@end

// used by joshua
@interface  CCDeleteRequest  :  ASIHTTPRequest  {
@private
    Class _deleteClass;
}

@property (nonatomic, readonly) Class deleteClass;

-(id)initWithURL:(NSURL *)newURL deleteClass:(Class)deleteClass;
@end