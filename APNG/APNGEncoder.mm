//
//  APNGEncoder.m
//  APNGAsm
//
//  Created by Morten Bertz on 6/26/16.
//  Copyright © 2016 telethon k.k. All rights reserved.
//

#import "APNGEncoder.h"
#import "apngasm.h"


@interface APNGEncoder ()


@end



@implementation APNGEncoder{
    apngasm::APNGAsm _assembler;
    NSURL *_outURL;
}


-(instancetype)init{
    self=[super init];
    if (self) {
        
    }
    return self;
}


-(instancetype)initWithURL:(NSURL *)url count:(NSUInteger)count{
    self=[super init];
    if (self) {
        _assembler=apngasm::APNGAsm();
        _outURL=url;
    }
    return self;
}

-(void)dealloc{
}



-(BOOL)addImage:(CGImageRef)frame withDelay:(NSTimeInterval)delay{
    BOOL success=NO;
    
    CGColorSpaceRef colorSpace = NULL;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *bitmapData;
    
    size_t bitsPerPixel = CGImageGetBitsPerPixel(frame);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(frame);
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(frame);
    size_t height = CGImageGetHeight(frame);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    bitmapData=(uint8_t*)calloc(bufferLength,1);
    CGContextRef context=  CGBitmapContextCreate(bitmapData, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), frame);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    if(context == nil){
        return NO;
    }
    
    apngasm::rgba *_pixels = (apngasm::rgba*)malloc(height * bytesPerRow);
    
    
    for (int i=0; i<width*height; ++i)
    {
        _pixels[i].r=bitmapData[4*i];
        _pixels[i].g=bitmapData[4*i+1];
        _pixels[i].b=bitmapData[4*i+2];
        _pixels[i].a=bitmapData[4*i+3];

    }
    
    apngasm::APNGFrame apng=apngasm::APNGFrame(_pixels, (unsigned int) width, (unsigned int)height, delay*1000, 1000);
    size_t retVal=_assembler.addFrame(apng);
    success |= retVal>0;
    free(bitmapData);
    free(_pixels);
    return success;
}

-(void)finalizeWithCompletion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion{
    BOOL success= _assembler.assemble(_outURL.fileSystemRepresentation);
    if (success) {
        completion(_outURL,nil);
    }
    else{
        completion(nil,nil);
    }
}


-(void)encodeFiles:(NSArray <NSURL*>* _Nonnull)files toURL:(NSURL* _Nonnull)outURL withCompletion:(void(^_Nonnull)(NSURL * _Nullable outURL, NSError * _Nullable error))completion{
    
    apngasm::APNGAsm assembler= apngasm::APNGAsm();
    
    for (NSURL *url in files) {
        assembler.addFrame(url.fileSystemRepresentation);
    }
    BOOL success= assembler.assemble(outURL.fileSystemRepresentation);
   
    
    if (success){
        completion(outURL,nil);
    }
    else{
#warning error not implemented
        completion(nil,nil);
    }
}





@end
