//
//  BBTransparentUserInteractionView.m
//  ScrollableImageViewSampler
//
//  Created by Takayoshi Otake on 2015/10/21.
//  Copyright © 2015 Takayoshi Otake. All rights reserved.
//

#import "BBTransparentUserInteractionView.h"

@implementation BBTransparentUserInteractionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        view = nil;
    }
    return view;
}

@end
