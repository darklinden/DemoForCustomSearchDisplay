//
//  VC_list.h
//  test
//
//  Created by darklinden on 14-4-26.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface O_list_item : NSObject
@property (nonatomic, strong) NSString *title;

+ (id)itemTitle:(NSString *)title;

@end

@interface VC_list : UIViewController

- (void)setup:(void (^)(SEL cancel, SEL done, NSArray **src_array))setup;

@end
