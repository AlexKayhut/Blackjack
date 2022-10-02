//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

@implementation Contestant

- (instancetype)initWith:(NSString *)name cards:(NSMutableArray *)cards chips:(NSInteger)chips isPlaying:(BOOL)isPlaying {
    self = [super init];
    if (self) {
        self.name = name;
        self.cards = cards;
        self.chips = chips;
        self.isPlaying = isPlaying;
    }
    return self;
}

-(NSMutableArray *) cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (NSInteger)cardsEvaluation {
    if (!_cardsEvaluation) _cardsEvaluation = 0;
    return _cardsEvaluation;
}
@end
