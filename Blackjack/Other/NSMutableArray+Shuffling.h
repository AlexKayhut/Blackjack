//
//  NSMutableArray+Shuffling.h
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)

- (void)shuffle;

@end

NS_ASSUME_NONNULL_END
