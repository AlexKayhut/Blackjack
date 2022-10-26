//
//  PlayerCellTableViewCell.m
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "PlayerCellTableViewCell.h"

@implementation PlayerCellTableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.name.text = @"";
    self.chips.text = @"";
    self.currentBet.text = @"";
    self.cardEvaluationLabel.text = @"";
    self.backgroundColor = UIColor.clearColor;
}

+ (NSString *)identifier {
    return @"PlayerCellTableViewCell";
}

@end
