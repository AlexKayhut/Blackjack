//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

@interface Contestant()

@end

@implementation Contestant

- (instancetype)initWith:(NSString *)name cards:(NSMutableArray *)cards chips:(NSInteger)chips {
    self = [super init];
    if (self) {
        self.name = name;
        self.cards = cards;
        self.chips = chips;
    }
    return self;
}

-(NSMutableArray *) cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}
@end
