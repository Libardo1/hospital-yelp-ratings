library(rjson)
library(ggplot2)
library(plyr)

ls <- list.files(path = "./json", pattern = "*.json")
zips <- lapply(ls, function(x) readLines(paste0(getwd(), "/json/", x)))
json_data <- lapply(zips, function(x) {
  fromJSON(fromJSON(paste(x, collapse = ""), 
                    unexpected.escape = "skip"))}
                    )
h <- sapply(json_data, function(x) length(x[[3]]))
json_data <- subset(json_data, h > 0)

h <- NULL
df <- lapply(1:length(json_data), 
             function(i) {j <- json_data[[i]]
                          h[i] <- do.call(rbind,
                                          lapply(1:length(j[[3]]), 
                                                 function(x) {df <- j[[3]][[x]]
                                                              list(name = df$id, 
                                                                   disp_name = df$name,
                                                                   rating = df$rating, 
                                                                   count = df$review_count, 
                                                                   address = df$location$address[1],
                                                                   city = df$location$city,
                                                                   state = df$location$state_code, 
                                                                   zip = df$location$postal_code,
                                                                   claimed = df$is_claimed,
                                                                   cat1 = df$categories[1][[1]][1],
                                                                   cat2 = df$categories[2][[1]][1],
                                                                   snip = df$snippet_text)}))})
df <- do.call(rbind.data.frame, df)
num <- c(3:4)
char <- c(1:2, 5:12)
df[,num] <- apply(df[,num], 2, function(x) as.numeric(x))
df[,char] <- apply(df[,char], 2, function(x) as.character(x))
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

#sub <- df[grepl('kaiser', df$name),]
sub <- df[grepl('^uc|ucla', df$name),]

ggplot(sub, aes(y = rating, x = reorder(name, rating))) + 
  geom_bar(stat = 'identity') + 
  coord_flip()

ggplot(df10, aes(x = rating)) + geom_histogram(binwidth = .5) + facet_grid(.~cut)

ggplot(df, aes(x = as.factor(rating), y = count, color = claimed)) + 
  geom_boxplot(position = 'dodge')

ggplot(df10, aes(x = rating)) + geom_histogram(binwidth = 1) + facet_grid(claimed~cut)
