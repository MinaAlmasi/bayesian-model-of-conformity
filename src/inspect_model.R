# def ratings
firstRating <- seq(from=1, to=8, by=1)
groupRating <- rep(8, 8)


# calc second rating
secondRating <- inv_logit_scaled(0.1 * logit_scaled(firstRating/9) + 0.9 * logit_scaled(groupRating/9) )
secondRating <- secondRating * 9

# combine into data frame
ratings <- data.frame(firstRating, groupRating, secondRating)

print(ratings)