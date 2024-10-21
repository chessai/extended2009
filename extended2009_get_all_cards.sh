#!/bin/bash

set -ex -o pipefail

# initial query url. this needs to be updated whenever the legality of the set
# updates (to make sure we're excluding the right things).
url="https://api.scryfall.com/cards/search?q=game%3Apaper%20date%3E%3D8ED%20date%3C%3DDDD%20-is%3Apromo%20-is%3Afunny%20-st%3Afrom_the_vault%20-set%3Awc03%20-set%3Awc04%20-set%3Aovnt"

cards='[]'

# scryfall paginates its results, capped at 175 cards per query
# this takes a couple-ish minutes.
while [ -n "$url" ]; do
    # avoid rate limiting
    sleep 1

    response=$(curl -s "$url")

    # `data` field has the list of card objects
    page_data=$(echo "$response" | jq '.data')
    cards=$(echo "$cards" "$page_data" | jq -s 'add')

    # scryfall returns the next page in the `next_page` field
    url=$(echo "$response" | jq -r '.next_page')

    # if `next_page` is null, stop the loop
    if [ "$url" == "null" ]; then
        url=""
    fi
done

# store concatenated results for debugging
echo "$cards" > extended2009_all_cards.json

# store an array of all the names, this is all we use.
# scryfall gives english names by default, even if there was never an english
# printing during that time.
jq '[.[] | .name]' extended2009_all_cards.json > extended2009_names.json
