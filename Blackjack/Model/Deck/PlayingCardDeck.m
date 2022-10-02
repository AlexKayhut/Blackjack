//
//  PlayingCardDeck.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

- (instancetype)init
{
    self = [super init];
    if (self) {
        for (NSString *suit in [PlayingCard validSuits]) {
            for (NSInteger rank = 0; rank <= [PlayingCard maxRank]; rank++) {
                PlayingCard *card = [[PlayingCard alloc] initWith:suit rank:rank];
                [self addCard:card];
            }
        }
        [self shuffle];
    }
    return self;
}

@end
