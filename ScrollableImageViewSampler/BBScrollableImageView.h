//
//  BBScrollableImageView.h
//  ScrollableImageViewSampler
//
//  Created by Takayoshi Otake on 2015/10/21.
//  Copyright © 2015 Takayoshi Otake. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface BBScrollableImageView : UIScrollView

@property (nullable, nonatomic, strong) IBInspectable UIImage *image;

@property (atomic, assign, readonly) CGFloat zoomScaleToFit;

@end
