//
//  Contestant.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Contestant : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray *cards;
@property (nonatomic) NSInteger chips;

- (instancetype)initWith:(NSString *)name cards:(NSMutableArray *)cards chips:(NSInteger)chips;

@end

NS_ASSUME_NONNULL_END
