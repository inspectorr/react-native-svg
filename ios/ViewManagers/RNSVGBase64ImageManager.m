/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSVGBase64ImageManager.h"

#import "RNSVGBase64Image.h"
#import "RCTConvert+RNSVG.h"

@implementation RNSVGBase64ImageManager

RCT_EXPORT_MODULE()

- (RNSVGRenderable *)node
{
    return [RNSVGBase64Image new];
}

RCT_EXPORT_VIEW_PROPERTY(scale, float)
RCT_EXPORT_VIEW_PROPERTY(dx, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(dy, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(base64, NSString)
RCT_EXPORT_VIEW_PROPERTY(atlasDescriptor, NSString)
RCT_EXPORT_VIEW_PROPERTY(frameDescriptor, NSString)

@end
