# Imports
Promise = require('bluebird')
request = Promise.promisifyAll(require('request'))
cheerio = require('cheerio')
fs = require('fs')
common = require('./common.coffee')

# Uses the cookie jar to access the sections page and scrapes all sections.
# Return a promise that resolves to an object wherein object keys are numbers 
# which map to section numbers (object key i = section i + 1)
# and array elements are objects with mentor name, mentor email, room #, time, and weekday
get_sections = (cookie_jar) ->
    day_mappings = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
    params = {
        url: common.SETTINGS.url+ '/sections'
        jar: cookie_jar
    }
    return request.getAsync(params).then (resp) ->
        sections = []

        $ = cheerio.load(resp.body)
        table = $('table.table_sections')
        rows = table.find('tr')
        rows.each (index) ->
            # For whatever reason, this is returning table columns not rows.
            # TODO: Look into why this is; in the meantime, it is a convenient bug
            day = day_mappings[index]
            row = $(this)
            row.find('td').each (index, element) ->
                day_index = index % day_mappings.length
                info = $(this).text().split('\n')     # Split data by newlines since each datapoint on different line
                info = (s.trim() for s in info)       # Strip whitespace (artifact of scraping)
                info = info.filter (s) -> s != ''     # Get rid of empty strings from the trim
                if info.length < 2
                    # If info is too short, either empty <td> or 
                    return

                # Process dat data or something
                times = info[4].split('-')
                enrollment = info[5].split('/')
                enrollment[1] = enrollment[1].split(' ')[0]

                section = {
                    'section_number': info[0].split(' ')[1]
                    'mentor_name': info[1]
                    'mentor_email': info[2]
                    'location': info[3]
                    'start_time': times[0]
                    'end_time': times[1]
                    'current_enrollment': enrollment[0]
                    'max_enrollment': enrollment[1]
                }
                sections.push section

        return sections


module.exports = {
    run: (filedir) ->
        common.login(common.SETTINGS.username, common.SETTINGS.password).then (cookie_jar) ->
            get_sections(cookie_jar)
        .then (sections) ->
            common.json_to_csv(filedir, Object.keys(sections[0]), sections)
        .catch (error)->
            console.log('Error: ' + error)
}
