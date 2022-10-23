//
//  Contestant.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>

@interface Contestant : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSMutableArray *cards;
@property (nonatomic) NSInteger chips;
@property (nonatomic) NSInteger cardsEvaluation;
@property (nonatomic) BOOL isPlaying;

- (instancetype)initWithName:(NSString *)name
                       cards:(NSMutableArray *)cards
                       chips:(NSInteger)chips
                   isPlaying: (BOOL)isPlaying;

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips;

@end
