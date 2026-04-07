#!/bin/sh

# list all of the files that will be loaded into the database
# for the first part of this assignment, we will only load a small test zip file with ~10000 tweets
# but we will write are code so that we can easily load an arbitrary number of files
files='
test-data.zip
'

echo 'load normalized'
for file in $files; do
    python3 load_tweets.py --inputs="$file" --db postgresql://postgres:pass@localhost:54318
    # call the load_tweets.py file to load data into pg_normalized
done

echo 'load denormalized'
for file in $files; do
    unzip -p "$file" | \
    jq -c 'walk(
      if type=="string" then
        gsub("\\\\"; "\\\\\\\\") |  # escape backslashes
        gsub("\r"; "")      |        # remove carriage returns
        gsub("\n"; "\\n")  |        # escape newlines
        gsub("\""; "\\\"")           # escape quotes
      else
        .
      end
    )' | \
    psql postgresql://postgres:pass@localhost:54317 \
      -c "\COPY tweets_jsonb (data) FROM STDIN"
    # use SQL's COPY command to load data into pg_denormalized
done
