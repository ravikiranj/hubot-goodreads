# Description:
#   Searches gooodreads for book
#
# Dependencies:
#   request
#   jsdom
#   fs
#
# Configuration:
#   HUBOT_GOODREADS_API_KEY
#
# Commands:
#   hubot (gr|goodreads|book) bookname - displays information about book name
#
# Author:
#   rjanardhana

regexp = /(gr|book|goodreads)\s+(.+)/i
request = require 'request'
jsdom = require 'jsdom'
fs = require 'fs'

JQUERY_FILEPATH = __dirname + '/../static/js/jquery.min.js'
jquery = fs.readFileSync(JQUERY_FILEPATH).toString()

if not process.env.HUBOT_GOODREADS_API_KEY?
    throw new Error("HUBOT_GOODREADS_API_KEY is not set! exiting!")

# Listen to regexp and respond
module.exports = (robot) ->
    robot.respond regexp, (msg) ->
        query = encodeURIComponent msg.match[2]
        errMsg = "There was an error fetching results from goodreads"
        goodreadsUrl = "https://www.goodreads.com/search/index.xml?key=#{process.env.HUBOT_GOODREADS_API_KEY}&q=#{query}"

        request.get goodreadsUrl, (error, response, data) ->
            if not response or response.statusCode != 200 or not data
                msg.send errMsg
                return
            try
                op = goodreadsRespHandler msg, response, data, query
            catch error
                op = errMsg + " for query = " + query
                robot.logger.error error
                robot.logger.error error.stack

            msg.send op

    ## Process Response
    goodreadsRespHandler = (msg, res, data, query) ->
        op = ""
        errMsg = "There was an error fetching results from goodreads for query = #{query}"
        scrape data,
            [
                "GoodreadsResponse search results work best_book title:first" ## title
                "GoodreadsResponse search results work best_book author name:first" ## author
                "GoodreadsResponse search results work original_publication_year:first" ## year
                "GoodreadsResponse search results work average_rating:first" ## rating
                "GoodreadsResponse search results work best_book id:first" ## id
            ],
            (results) ->
                u = "Unknown"
                grUrlPrefix = "https://www.goodreads.com/book/show/"
                title = if results[0]? then results[0] else u
                author = if results[1]? then results[1] else u
                year = if results[2]? then results[2] else u
                rating = if results[3]? then results[3] else u
                grUrl = if results[4]? then grUrlPrefix + results[4] else u
                op = "#{title} (#{year}) - #{author}, Rating = #{rating}/5.00\n"
                msg.send op
                msg.send "Goodreads = #{grUrl}"

    ## Scrape
    # scrape (already retrieved) HTML
    # selectors: an array of jquery selectors
    # callback: function that takes scrape results
    scrape = (body, selectors, callback) ->
        jsdom.env html: body, src: [jquery], done: (errors, window) ->
            # use jquery to run selector and return the elements
            callback (window.$(selector).text().trim() for selector in selectors)#
