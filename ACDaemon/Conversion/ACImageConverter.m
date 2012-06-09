//
//  ACPNGJPGConverter.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACImageConverter.h"

@implementation ACImageConverter

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    NSArray * supported = [NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", @"bmp", @"tiff", @"gif", @"jp2", nil];
    if ([supported containsObject:oldExt] && [supported containsObject:newExt]) {
        return YES;
    }
    return NO;
}

- (void)convertSynchronously:(ACConverterCallback)callback {
    // decode image
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:file];
    if ([[NSThread currentThread] isCancelled]) return;
    callback(ACConverterCallbackTypeProgress, 0.4, nil);
    
    NSData * data = nil;
    NSBitmapImageRep * imgRep = [[image representations] objectAtIndex: 0];
    if ([self.destExtension isEqualToString:@"png"]) {
        data = [imgRep representationUsingType:NSPNGFileType properties:nil];
    } else if ([self.destExtension isEqualToString:@"jpeg"] || [self.destExtension isEqualToString:@"jpg"]) {
        NSDictionary * properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                                forKey:NSImageCompressionFactor];
        data = [imgRep representationUsingType:NSJPEGFileType properties:properties];
    } else if ([self.destExtension isEqualToString:@"jp2"]) {
        NSDictionary * properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                                forKey:NSImageCompressionFactor];
        data = [imgRep representationUsingType:NSJPEG2000FileType properties:properties];
    } else if ([self.destExtension isEqualToString:@"gif"]) {
        data = [imgRep representationUsingType:NSGIFFileType properties:nil];
    } else if ([self.destExtension isEqualToString:@"tiff"]) {
        data = [imgRep representationUsingType:NSTIFFFileType properties:nil];
    } else if ([self.destExtension isEqualToString:@"bmp"]) {
        data = [imgRep representationUsingType:NSBMPFileType properties:nil];
    }
    if ([[NSThread currentThread] isCancelled]) return;
    if (![data writeToFile:tempFile atomically:YES]) {
        NSDictionary * info = [NSDictionary dictionaryWithObject:@"Failed to write image data"
                                                          forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:@"ACPNGJPGConverter" code:1 userInfo:info];
        callback(ACConverterCallbackTypeError, 0, error);
        return;
    }
    if ([[NSThread currentThread] isCancelled]) return;

    callback(ACConverterCallbackTypeProgress, 0.9, nil);
    
    [NSThread sleepForTimeInterval:0.1];
    
    NSError * finError;
    if (![self placeTempFile:&finError]) {
        callback(ACConverterCallbackTypeError, 0, finError);
        return;
    }
}

@end
