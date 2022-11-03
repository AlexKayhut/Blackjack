//
//  Deck.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "NSMutableArray+Shuffling.h"

@interface Deck : NSObject

@property (nonatomic, copy, readonly) NSArray *cards;

- (void)addCard:(Card *)card;
- (void)shuffle;

- (Card *)drawRandomCardWithFaceUp:(BOOL) isFaceUp;

@end
