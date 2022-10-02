//
//  Deck.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "NSMutableArray_Shuffling.h"

@interface Deck : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *cards;

- (void)addCard:(Card *)card;
- (void)shuffle;

- (Card *)drawRandomCard:(BOOL) isFaceUp;

@end
