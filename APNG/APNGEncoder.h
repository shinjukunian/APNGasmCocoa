//
//  APNGEncoder.h
//  APNGAsm
//
//  Created by Morten Bertz on 6/26/16.
//  Copyright © 2016 telethon k.k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface APNGEncoder : NSObject

@property double delayTime;
@property BOOL loop;



-(void)encodeFiles:(NSArray <NSURL*>* _Nonnull)files toURL:(NSURL* _Nonnull)outURL withCompletion:(void(^_Nonnull)(NSURL * _Nullable outURL, NSError * _Nullable error))completion;

-(nullable instancetype)initWithURL:(nonnull NSURL*)url count:(NSUInteger)count;

-(BOOL)addImage:(nonnull CGImageRef)image withDelay:(NSTimeInterval)delay;
-(void)finalizeWithCompletion:(void(^_Nonnull)(NSURL *_Nullable outURL , NSError *_Nullable error ))completion;

@end
