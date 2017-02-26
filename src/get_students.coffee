# Imports
Promise = require('bluebird')
request = Promise.promisifyAll(require('request'))
cheerio = require('cheerio')
fs = require('fs')
common = require('./common.coffee')

get_students = (cookie_jar) ->
    params = {
        url: common.SETTINGS.url + '/admin/manage_attendance'
        jar: cookie_jar
    }
    return request.getAsync(params).then (resp) ->
        students = []
        $ = cheerio.load(resp.body)
        $('div.roster li.list-group-item').each (index) ->
            info = $(this).text().trim().split('\n')
            info = (s.trim() for s in info).filter (s) -> s != ''
            get_digit = common.get_digit

            students.push {
                name: info[0]
                email: info[1]
                approved: get_digit(info[2])
                excused: get_digit(info[3])
                pending: get_digit(info[4])
                unexcused: info[6]
            }
        return students

module.exports = {
    run: (filedir) ->
        common.login(common.SETTINGS.username, common.SETTINGS.password).then (cookie_jar) ->
            get_students(cookie_jar)
        .then (students) ->
            common.json_to_csv(filedir, Object.keys(students[0]), students)

    filter_by_max_absence: (filedir, max) ->
        common.login(common.SETTINGS.username, common.SETTINGS.password).then (cookie_jar) ->
            get_students(cookie_jar)
        .then (students) ->
            max = parseInt(max)
            students.filter (student) -> student.unexcused > max
        .then (students) ->
            common.json_to_csv(filedir, Object.keys(students[0]), students)
}
