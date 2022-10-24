//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"
#import "BlackjackGame.h"
#import "PlayingCard.h"

@interface Contestant ()

@property (nonatomic) NSArray<Card *> *cards;
@property (nonatomic) NSInteger cardsEvaluation;
@property (nonatomic, weak, nullable) id<PlayerDelegate> delegate;

@end

@implementation Contestant

@synthesize chips = _chips;

- (instancetype)initWithName:(NSString *)name cards:(NSArray *)cards chips:(NSInteger)chips state:(ContestantState)state {
    self = [super init];
    if (self) {
        _name = name;
        _cards = cards;
        _chips = chips;
        _state = state;
        _cardsEvaluation = 0;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips {
    return [self initWithName:name cards:[NSMutableArray new] chips:chips state:BETTING];
}

- (NSInteger)chips {
    if (!_chips) {
        _chips = 0;
    }
    [self.delegate stateUpdatedFor:self];
    return _chips;
}

- (void)acceptNewCard:(Card *)card {
    NSMutableArray<Card *> *mutableCards = [NSMutableArray arrayWithCapacity:self.cards.count];
    [mutableCards addObjectsFromArray:self.cards];
    [mutableCards addObject:card];
    self.cards = mutableCards;
    [self updateCardEvaluation];
}

- (void)wonChipsAmount:(NSInteger)winAmount {
    self.chips += winAmount;
}

-(NSInteger)updateCardEvaluation {
    NSInteger contestantCardsEvaluation = 0;
    
    for (PlayingCard *card in self.cards) {
        if (!card.isAce) {
            contestantCardsEvaluation += BlackjackGame.cardValues[card.cardValue].integerValue;
        }
    }
    
    self.cardsEvaluation = [self addAceLogicToCardsEvaluation:contestantCardsEvaluation];
    ContestantState oldState = self.state;
    
    if (self.cardsEvaluation == BlackjackGame.cardsAmountToWin) {
        self.state = GOT_BLACKJACK;
    } else if (self.cardsEvaluation > BlackjackGame.cardsAmountToWin) {
        self.state = LOST;
    } else {
        self.state = PLAYING;
    }
    
    if (oldState != self.state || self.state == BETTING) {
        [self.delegate stateUpdatedFor:self];
    }
    
    return contestantCardsEvaluation;
}

-(NSInteger)addAceLogicToCardsEvaluation:(NSInteger)cardsEvaluation {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PlayingCard *value, NSDictionary *bindings) {
        return [value.cardValue  isEqual: @"A"];
    }];
    
    NSInteger numberOfAcesInHand = [self.cards filteredArrayUsingPredicate:predicate].count;
    if (numberOfAcesInHand == 0) {
        return cardsEvaluation;
    }
    
    const int aceFirstPossibility = 11;
    const int aceSecondPossibility = 1;
    
    for (int i=0; i<numberOfAcesInHand;i++) {
        if ((self.cardsEvaluation + aceFirstPossibility) <= BlackjackGame.cardsAmountToWin) {
            self.cardsEvaluation += aceFirstPossibility;
        } else if ((self.cardsEvaluation + aceSecondPossibility) <= BlackjackGame.cardsAmountToWin) {
            self.cardsEvaluation += aceSecondPossibility;
        }
    }
    
    return cardsEvaluation;
}

@end
