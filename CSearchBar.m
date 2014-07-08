//
//  CSearchBar.m
//  EasyReimburse
//
//  Created by darklinden on 14-4-26.
//  Copyright (c) 2014年 com.comcsoft. All rights reserved.
//

#import "CSearchBar.h"

@implementation CSearchBar

- (BOOL)resignFirstResponder
{
    BOOL ret = [super resignFirstResponder];
    
    if (self.showsCancelButton) {
        for (UIView *v in self.subviews) {
            for (UIView *sv in v.subviews) {
                if ([sv isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                    UIButton *btn = (UIButton *)sv;
                    btn.enabled = YES;
                }
//                NSLog(@"sv %@", sv);
            }
            if ([v isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                UIButton *btn = (UIButton *)v;
                btn.enabled = YES;
            }
//            NSLog(@"v %@", v);
        }
    }
    
    return ret;
}

@end
