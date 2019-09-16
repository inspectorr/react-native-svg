/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "RNSVGRenderable.h"

@interface RNSVGBase64Image : RNSVGRenderable
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) NSInteger dx;
@property (nonatomic, assign) NSInteger dy;
@property (nonatomic, strong) NSString* base64;
@property (nonatomic, strong) NSString* atlasDescriptor;
@property (nonatomic, strong) NSString* frameDescriptor;

@end
