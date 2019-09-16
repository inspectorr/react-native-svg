/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSVGBase64Image.h"
#import "RCTConvert+RNSVG.h"
#import <React/RCTLog.h>

@implementation RNSVGBase64Image
{
    CGImageRef image;
    UIImage *base64Image;
    NSArray *frameArray;
    NSMutableDictionary *subtexturesDict;
    bool base64Updated;
    bool descriptorUpdated;
    bool frameUpdated;
}

- (void)setDx:(NSInteger)dx
{
    if (dx == _dx) {
        return;
    }
    [self invalidate];
    _dx = dx;
}

- (void)setDy:(NSInteger)dy
{
    if (dy == _dy) {
        return;
    }
    [self invalidate];
    _dy = dy;
}

- (void)setScale:(float)scale
{
    if (scale == _scale) {
        return;
    }
    [self invalidate];
    _scale = scale;
}

- (void)setBase64:(NSString *)base64
{
    if (base64 == _base64) {
        return;
    }
    [self invalidate];
    _base64 = base64;
    if ([_base64 length] != 0) {
        NSString *prefix = @"data:image/png;base64,";
        NSURL *url = [NSURL URLWithString:[prefix stringByAppendingString:base64]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        base64Image = [UIImage imageWithData:imageData];
        base64Updated = true;
        if (descriptorUpdated == true) [self updateSubtextures];
    }
}

- (void)setAtlasDescriptor:(NSString *)atlasDescriptor
{
    if (atlasDescriptor == _atlasDescriptor) {
        return;
    }
    [self invalidate];
    _atlasDescriptor = atlasDescriptor;
    if ([_atlasDescriptor length] != 0) {
        descriptorUpdated = true;
        if (base64Updated == true) [self updateSubtextures];
    }
}

- (void)setFrameDescriptor:(NSString *)frameDescriptor
{
    frameUpdated = false;
    if (frameDescriptor == _frameDescriptor) {
        return;
    }
    [self invalidate];
    _frameDescriptor = frameDescriptor;
    if ([_frameDescriptor length] != 0) {
        NSData *responseData = [_frameDescriptor dataUsingEncoding:NSUTF8StringEncoding];
        frameArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        frameUpdated = true;
    }
}

- (void)updateSubtextures
{
    base64Updated = false;
    descriptorUpdated = false;
    NSData *responseData = [_atlasDescriptor dataUsingEncoding:NSUTF8StringEncoding];
    subtexturesDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
}

- (void)dealloc
{
    CGImageRelease(image);
}

- (void)renderLayerTo:(CGContextRef)context rect:(CGRect)rect
{
    if (frameUpdated == true) {
        CGRect box = CGContextGetClipBoundingBox(context);
        float height = CGRectGetHeight(box);
        float width = CGRectGetWidth(box);
        
        CGFloat x = 0;
        CGFloat y = 0;
        
        CGRect rect = CGRectMake(x, y, width, height);
        // add hit area
        self.hitArea = CFAutorelease(CGPathCreateWithRect(rect, nil));
        
        if (self.opacity == 0) {
            return;
        }
        
        [self clip:context];

        frameUpdated = false;
        if (frameArray != nil && subtexturesDict != nil && [_base64 length] != 0) {
            if ([NSJSONSerialization isValidJSONObject:frameArray] && [NSJSONSerialization isValidJSONObject:subtexturesDict]) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, height);
                CGContextScaleCTM(context, 1.0, -1.0);
                CGContextScaleCTM(context, _scale, _scale);
                for (int index = 0; index < [frameArray count]; index++) {
                    NSString *subTextureName = [frameArray[index] objectForKey:@"n"];
                    NSDictionary *transform = [frameArray[index] objectForKey:@"t"];
                    float a = [[transform valueForKey:@"a"] floatValue];
                    float b = [[transform valueForKey:@"b"] floatValue];
                    float c = [[transform valueForKey:@"c"] floatValue];
                    float d = [[transform valueForKey:@"d"] floatValue];
                    float tx = [[transform valueForKey:@"tx"] floatValue];
                    float ty = [[transform valueForKey:@"ty"] floatValue];
                    
                    if ([subtexturesDict objectForKey:subTextureName] != nil) {
                        NSDictionary *value = [subtexturesDict objectForKey:subTextureName];
                        int w = [[value valueForKey:@"w"] integerValue];
                        int h = [[value valueForKey:@"h"] integerValue];
                        int x = [[value valueForKey:@"x"] integerValue];
                        int y = [[value valueForKey:@"y"] integerValue];
                        int rx = [[value valueForKey:@"rx"] integerValue];
                        int ry = [[value valueForKey:@"ry"] integerValue];

                        CGAffineTransform current = CGAffineTransformMake(a, -b, -c, d, tx + _dx, -ty + height - _dy);

                        CGContextConcatCTM(context, current);
                        
                        CGImageRef subImage = CGImageCreateWithImageInRect(base64Image.CGImage, CGRectMake(x, y, w, h));
                        CGContextDrawImage(context, CGRectMake(rx, -ry - h, w, h), subImage);
                        CGImageRelease(subImage);
                        
                        CGContextConcatCTM(context, CGAffineTransformInvert(current));
                    }
                }
                CGContextRestoreGState(context);
            }
        }
    }
}

@end
