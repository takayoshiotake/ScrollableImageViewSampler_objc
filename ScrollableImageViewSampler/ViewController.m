//
//  ViewController.m
//  ScrollableImageViewSampler
//
//  Created by Takayoshi Otake on 2015/10/21.
//  Copyright © 2015 Takayoshi Otake. All rights reserved.
//

#import "ViewController.h"
#import "BBScrollableImageView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet BBScrollableImageView *scrollableImageView;

@end

@implementation ViewController

- (IBAction)action1:(id)sender {
    self.scrollableImageView.image = nil;
}

- (IBAction)action2:(id)sender {
    self.scrollableImageView.image = [UIImage imageNamed:@"sample_large"];
}

- (IBAction)action3:(id)sender {
    self.scrollableImageView.image = [UIImage imageNamed:@"sample_regular"];
}

- (IBAction)action4:(id)sender {
    self.scrollableImageView.image = [UIImage imageNamed:@"sample_small"];
}

@end
