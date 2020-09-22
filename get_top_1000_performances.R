# URL: https://www.beermile.com/records
# YouTube race: https://www.youtube.com/watch?v=JpNBmBlz0n8
# champs start at 23 mins

# Rules https://www.beermile.com/rules
# Rule variations https://www.beermile.com/variations

# TO DO:
# - Extract table of results, e.g. https://www.beermile.com/records/ref_wr

library(rvest)
library(dplyr)
library(stringr)

top_1000 <- 'https://www.beermile.com/records/ref_wr'
top_1000_html <- read_html(top_1000)

top_1000_df <- as.data.frame(top_1000_html %>% html_table(fill=TRUE, header=TRUE))
# df missing links and truncates race name
top_1000_df$Name <- gsub('  ',' ',top_1000_df$Name)

nodes <- as.character(html_nodes(top_1000_html,'td a'))
event_nodes <- nodes[grepl('display/event',nodes)]

top_1000_df$beer_url <- paste0('https://www.beermile.com/records/ref_beer/beertype_',gsub(' ','+',top_1000_df$Beer))
top_1000_df$name_url <- paste0('https://www.beermile.com/query_indy/submit_1/ref_query/name_',gsub(' ','+',top_1000_df$Name))

top_1000_df$event_url <- paste0('https://www.beermile.com/',stringr::str_extract(event_nodes,"display\\/event_\\d+"))

# Race metadata workaround
for(i in 1:length(top_1000_df$event_url)){
  print(i)
  race <- top_1000_df$event_url[i]
  race_html <- read_html(race)
  
  race_nodes <- html_nodes(race_html,'font')
  race_nodes_clean <- stringr::str_extract(as.character(race_nodes),'>(.)*<')
  race_nodes_clean <- substr(race_nodes_clean,2,nchar(race_nodes_clean)-1)
  
  race_name <- race_nodes_clean[1]
  race_loc <- race_nodes_clean[2]
  race_date <- race_nodes_clean[3]
  
  race_df <- data.frame(url=race,event_name=race_name,event_location=race_loc,event_date=race_date,stringsAsFactors = F)
  
  if(i == 1){
    all_events <- race_df
  }
  
  if(i != 1){
    all_events <- rbind(all_events,race_df)
  }
}

beer_mile_df <- dplyr::left_join(top_1000_df,all_events, by = c("event_url" = "url"))
write.csv(beer_mile_df,"data/top_1000_beer_mile_performances.csv", row.names = F)
