## EPPS 6302 Assignment 2: Google Trends pulls from R
## Runs every gtrends() call once and caches the results, so the write-up
## works from saved files instead of hitting Google again.
## On the first run three calls failed (the first call, the Kamala Harris query and
## US/GB/TW). They were re-run a few minutes later with the same arguments, in
## that order. Because the first "repeat" below ran before the first call had
## succeeded, the repeat was run once more afterwards ("repeat2"), and the page
## compares the first call with repeat2. Every attempt is in r_pull_log.csv.

library(gtrendsR)
library(readr)

out <- "data/gtrends"
log_file <- file.path(out, "r_pull_log.csv")
if (!file.exists(log_file)) write_csv(data.frame(name = character(), pulled_utc = character(), ok = logical()), log_file)

pull <- function(name, ...) {
  res <- tryCatch(gtrends(...), error = function(e) { message(name, " failed: ", conditionMessage(e)); NULL })
  stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S", tz = "UTC")
  write_csv(data.frame(name = name, pulled_utc = stamp, ok = !is.null(res)), log_file, append = TRUE)
  if (!is.null(res)) saveRDS(res, file.path(out, paste0("r_", name, ".rds")))
  Sys.sleep(20)  # be kind to the endpoint
  res
}

# First call, as in the assignment
TrumpHarrisElection <- pull("trump_harris_election_us_5y",
                            c("Trump", "Harris", "election"),
                            onlyInterest = TRUE,
                            geo          = "US",
                            gprop        = "web",
                            time         = "today+5-y",   # last five years
                            category     = 0)
if (!is.null(TrumpHarrisElection)) {
  the_df <- TrumpHarrisElection$interest_over_time
  # Cache the raw pull - the next call will not return the same numbers
  write_csv(the_df, file.path(out, paste0("gtrends_us_5y_", Sys.Date(), ".csv")))
}

# Same query as the website pull (Kamala Harris instead of Harris)
pull("trump_kamalaharris_election_us_5y", c("Trump", "Kamala Harris", "election"),
     onlyInterest = TRUE, geo = "US", gprop = "web", time = "today+5-y", category = 0)

# Rest of gtrendsR01.R
pull("tariff_all", "tariff", time = "all")
pull("tariff_gb_all", "tariff", geo = "GB", time = "all")
pull("tariff_us_gb_tw_all", "tariff", geo = c("US", "GB", "TW"), time = "all")
pull("tct_all", c("tariff", "China military", "Taiwan"), time = "all")

# Note on terms: Harris vs Kamala Harris on their own
pull("harris_us_5y", "Harris", onlyInterest = TRUE, geo = "US", gprop = "web", time = "today+5-y", category = 0)
pull("kamalaharris_us_5y", "Kamala Harris", onlyInterest = TRUE, geo = "US", gprop = "web", time = "today+5-y", category = 0)

# Section 7: the same first call again, a few minutes later
pull("trump_harris_election_us_5y_repeat", c("Trump", "Harris", "election"),
     onlyInterest = TRUE, geo = "US", gprop = "web", time = "today+5-y", category = 0)

# Section 7 again, after the first call had succeeded on retry
pull("trump_harris_election_us_5y_repeat2", c("Trump", "Harris", "election"),
     onlyInterest = TRUE, geo = "US", gprop = "web", time = "today+5-y", category = 0)
