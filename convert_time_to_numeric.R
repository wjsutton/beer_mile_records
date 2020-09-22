# Parsing time string in numeric for Tableau
data <- read.csv("data/top_1000_beer_mile_performances.csv")

data$minute <- as.integer(substr(data$Time,1,1))
data$seconds <- as.numeric(substr(data$Time,3,10))

data$total_time_in_secs <- data$seconds + data$minute*60.0

write.csv(data,"data/top_1000_beer_mile_performances_with_times.csv",row.names = F)
