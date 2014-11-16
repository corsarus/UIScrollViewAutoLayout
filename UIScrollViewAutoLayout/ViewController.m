//
//  ViewController.m
//  UIScrollViewAutoLayout
//
//  Created by Catalin (iMac) on 16/11/2014.
//  Copyright (c) 2014 Catalin Rosioru. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *widthConstraints;
@property (nonatomic) NSUInteger minSquareEdgeSize;
@property (nonatomic) NSUInteger maxSquareEdgeSize;

@end

@implementation ViewController

CGFloat static kSpacing = 10.0;

- (NSMutableArray *)widthConstraints
{
    if (!_widthConstraints) {
        _widthConstraints = [[NSMutableArray alloc] init];
    }
    
    return _widthConstraints;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addSquareSubviewsToView:self.scrollView rowNumber:10 colNumber:4];
}


- (void)addSquareSubviewsToView:(UIView *)view rowNumber:(NSUInteger)rows colNumber:(NSUInteger)columns
{
    // compute the square edge size for each orientation according to the spacing and the number of columns
    [self squareEdgeSizesForColumnNumber:columns];
    NSUInteger squareEdgeSize = [self edgeSizeForOrientation:[UIDevice currentDevice].orientation];
    
    NSString *horizontalConstraints;
    NSString *verticalConstraints = @"";
    NSMutableDictionary *horizontalViewsDictionary;
    NSMutableDictionary *verticalViewsDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSUInteger i = 0; i < rows; i++) {
    
        UIColor *colorForRow = [self randomColor];

        horizontalConstraints = @"";
        horizontalViewsDictionary = [[NSMutableDictionary alloc] init];
        
        UIView *leftSquare = nil;
        
        for (NSUInteger j = 0; j < columns; j++) {
            
            UIView *newSquare = [[UIView alloc] init];
            newSquare.translatesAutoresizingMaskIntoConstraints = NO;
            newSquare.backgroundColor = colorForRow;
            
            UIView *spacingView = [[UIView alloc] init];
            spacingView.translatesAutoresizingMaskIntoConstraints = NO;
            spacingView.backgroundColor = [UIColor clearColor];
            
            if (j == 0) {
                verticalConstraints = [verticalConstraints stringByAppendingString:[NSString stringWithFormat:@"(spacing)-[square_%d]-", (int)i]];
                [verticalViewsDictionary setObject:newSquare forKey:[NSString stringWithFormat:@"square_%d", (int)i]];
                
                // set the width for the first square in each row and store it to able to modify it later, when the orientation changes
                NSLayoutConstraint *squareWidth = [NSLayoutConstraint constraintWithItem:newSquare
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute                                                                              multiplier:1.0 constant:(CGFloat)squareEdgeSize];
                [newSquare addConstraint:squareWidth];
                [self.widthConstraints addObject:squareWidth];
            }
            
            [view addSubview:newSquare];
            
            // make the width equal to the height
            [newSquare addConstraint:[NSLayoutConstraint constraintWithItem:newSquare
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:newSquare
                                                                 attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0 constant:0.0]];
            if (leftSquare) {
                // make new square the same width as its left neighbour
                [view addConstraint:[NSLayoutConstraint constraintWithItem:newSquare
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:leftSquare
                                                                      attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0 constant:0.0]];
            }
            leftSquare = newSquare;
            
            horizontalConstraints = [horizontalConstraints stringByAppendingString:[NSString stringWithFormat:@"(spacing)-[square_%d]-", (int)j]];
            [horizontalViewsDictionary setObject:newSquare forKey:[NSString stringWithFormat:@"square_%d", (int)j]];
        }
        
        // for each row, pin the first square to the left edge of the scroll view, and the last square to the right edge
        horizontalConstraints = [NSString stringWithFormat:@"H:|-%@(spacing)-|", horizontalConstraints];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints
                                                                                options:NSLayoutFormatAlignAllCenterY
                                                                                metrics:@{@"spacing": @(kSpacing)}
                                                                                  views:horizontalViewsDictionary]];
    }
    
    // pin the first square of the first column to the top edge of the scroll view, and the last square to the bottom edge
    verticalConstraints = [NSString stringWithFormat:@"V:|-%@(spacing)-|", verticalConstraints];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                           options:NSLayoutFormatAlignAllCenterX
                                                                           metrics:@{@"spacing": @(kSpacing)}
                                                                              views:verticalViewsDictionary]];
}

- (UIColor *)randomColor
{
    CGFloat red = 1.0;
    CGFloat green = 1.0;
    CGFloat blue = 1.0;
    
    // any color but white
    while (red == 1.0 && green == 1.0 && blue == 1.0) {
        red = arc4random() / INT_MAX;
        green = arc4random() / INT_MAX;
        blue = arc4random() / INT_MAX;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (void)squareEdgeSizesForColumnNumber:(NSUInteger)columns
{
    
    self.minSquareEdgeSize = (NSUInteger)(([UIScreen mainScreen].bounds.size.width - (kSpacing * (columns + 1))) / columns);

    self.maxSquareEdgeSize = (NSUInteger)(([UIScreen mainScreen].bounds.size.height - (kSpacing * (columns + 1))) / columns);
   
}

- (NSUInteger)edgeSizeForOrientation:(UIDeviceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return self.minSquareEdgeSize;
    } else {
        return self.maxSquareEdgeSize;
    }
}

- (void)viewWillLayoutSubviews
{
    for (NSLayoutConstraint *constraint in self.widthConstraints) {
        constraint.constant = (CGFloat)[self edgeSizeForOrientation:[UIDevice currentDevice].orientation];
    }
}

@end
