library(rjson)
library(ggplot2)
library(plyr)

ls <- list.files(pattern = "*.txt")
hsp <- lapply(ls, function(x) readLines(paste0(getwd(), "/", x)))
k <- lapply(hsp, function(x) fromJSON(fromJSON(paste(x, collapse = ""), unexpected.escape = "skip")))
df <- lapply(1:length(hsp), function(i) {
  h <- NULL
  j <- k[[i]]
  h[i] <- do.call(rbind, 
                  lapply(1:length(j[[3]]), function(x) {
                          df <- j[[3]][[x]]
                          list(name = df$id, 
                               disp_name = df$name,
                               rating = df$rating, 
                               count = df$review_count, 
                               address = df$location$address,
                               city = df$location$city,
                               state = df$location$state_code, 
                               zip = df$location$postal_code,
                               claimed = df$is_claimed,
                               category = df$categories[[1]])
                          }))
  })
df <- do.call(rbind.data.frame, df)
num <- c(3:4)
char <- c(1:2, 5:9)
df[,num] <- apply(df[,num], 2, function(x) as.numeric(x))
df[,char] <- apply(df[,char], 2, function(x) as.character(x))

df <- df[!duplicated(df$name),]
ggplot(df, aes(x = count)) + geom_histogram(binwidth = 5)

df10 <- df[df$count >= 10,]
df10$cut <- with(df10, cut(count, breaks = quantile(df10$count, probs = seq(0, 1, .25)), include.lowest = TRUE))
table(df10$cut, useNA = "ifany")
ggplot(df10, aes(x = rating, color = cut)) + geom_density()

dph <- c("highland-hospital", "contra", "kern", "natividad", "ucla", "riverside-county", 
         "santa-clara-valley", "san-mateo-medical-center", "lac-usc", "olive-view", 
         "rancho", "san-francisco-general", "san-joaquin-general", "alameda-count",
         "ucsf", "uc-davis", "uci-", "uc-san-diego", "ucsd", "ventura-county")
dph <- df10[grep(paste(dph, collapse="|"), df10$name),]

#sub <- df[grepl('kaiser', df$name),]
sub <- df[grepl('^uc|ucla', df$name),]

ggplot(sub, aes(y = rating, x = reorder(name, rating))) + 
  geom_bar(stat = 'identity') + 
  coord_flip()

ggplot(df10, aes(x = rating)) + geom_histogram(binwidth = .5) + facet_grid(.~cut)

lines <- ddply(df, .(claimed), summarize, count = median(count), rating = median(rating))
ggplot(df, aes(x = rating, y = count, color = claimed)) + 
  geom_point(position = 'jitter') + 
  geom_hline(data = lines, aes(yintercept = count, color = claimed)) + 
  geom_vline(data = lines, aes(xintercept = rating, color = claimed))
