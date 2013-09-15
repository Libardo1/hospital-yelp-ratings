library(ggplot2)
library(plyr)

ls <- list.files(path = "./data", pattern = "*.csv")
yelp_list <- lapply(ls, function(x) read.csv(file = paste0("./data/", x), header = F, stringsAsFactors = F))
df <- do.call(rbind.data.frame, yelp_list)

col <- c('id', 'is_claimed', 'is_closed', 'name', 'count', 'categories', 'rating', 
         'snippet_text', 'address_1', 'address_2', 'city', 'state', 'zip')
colnames(df) <- col

df <- df[(!duplicated(df$name) & df$state == "CA"),]

ggplot(df, aes(x = count)) + geom_histogram(binwidth = 5)

df10 <- df[df$count >= 10,]
df10$cut <- with(df10, cut(count, breaks = quantile(df10$count, probs = seq(0, 1, .25)), 
                           include.lowest = TRUE))
table(df10$cut, useNA = "ifany")
ggplot(df10, aes(x = rating, color = cut)) + geom_density()

dph <- c("highland-hospital", "contra", "kern", "natividad", "ucla", "riverside-county", 
         "santa-clara-valley", "san-mateo-medical-center", "lac-usc", "olive-view", 
         "rancho-los", "san-francisco-general", "san-joaquin-general", "alameda-count",
         "ucsf", "uc-davis", "uci-", "uc-san-diego", "ucsd", "ventura-county")
dph <- df[grepl(paste(dph, collapse="|"), df$name),]
dph <- dph[order(dph$disp_name),]

ggplot(dph[dph$count > 15,], aes(y = rating, x = reorder(name, rating))) + 
  geom_bar(stat = 'identity') + 
  coord_flip() + 
  ggtitle("DPH Yelp Ratings as of 9/8/2013\nScale: 0-5, includes only DPHs with > 15 reviews\n") + 
  xlab(NULL) + 
  scale_y_discrete(limits = 1:5)

#sub <- df[grepl('kaiser', df$name),]
sub <- df[grepl('^uc|ucla', df$name),]

ggplot(sub, aes(y = rating, x = reorder(name, rating))) + 
  geom_bar(stat = 'identity') + 
  coord_flip()

ggplot(df10, aes(x = rating)) + geom_histogram(binwidth = .5) + facet_grid(.~cut)

ggplot(df, aes(x = as.factor(rating), y = count, color = claimed)) + 
  geom_boxplot(position = 'dodge')

ggplot(df10, aes(x = rating)) + geom_histogram(binwidth = 1) + facet_grid(claimed~cut)
