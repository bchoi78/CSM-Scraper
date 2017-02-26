Promise = require('bluebird')
request = Promise.promisifyAll(require('request'))
cheerio = require('cheerio')
fs = require('fs')
yaml = require('js-yaml')

SETTINGS_DIR = './settings.yaml'
SETTINGS = {}

# Logs into the Scheduler
# Returns a Promise wherein the next method in the promise chain will receive a cookie jar
# that maintains the session for having logged into scheduler
login = (username, password) ->
    PATH = '/users/sign_in'
    COOKIE_JAR = request.jar()
    params = {
        url: SETTINGS.url + PATH
        jar: COOKIE_JAR
    }
    return request.getAsync(params).then (resp) ->
        $ = cheerio.load(resp.body)
        token_element = $('input[name="authenticity_token"]')[0]
        return token_element.attribs.value
    .then (csrf_token)->
        req_params = {
            'url': SETTINGS.url + PATH
            'form': {
                'utf8': '✓'
                'authenticity_token': csrf_token
                'user[email]': username
                'user[password]': password 
                'user[remember_me]': '0'
                'commit': 'Log in'
            }
            jar: COOKIE_JAR
        }
        return request.postAsync(req_params).then (resp) ->
            return COOKIE_JAR

# Writes a csv with filename
json_to_csv = (filename, columns, data) ->
    str = columns.join(',') + '\n'

    for d in data
        for column in columns
            str += '"' + d[column] + '",'
        str = str[..-2] + '\n'

    fs.writeFile filename, str, (err) ->
        if err?
            console.log 'Writing to file failed... Error: ' + err
    return

# Gets the first digit of the given string (or return the entire list if all is true
get_digit = (s, all) ->
    reg = /\d+/g
    matches = s.match(reg)
    if all
        return matches
    return matches[0]

load_settings = () ->
    SETTINGS = yaml.safeLoad(fs.readFileSync(SETTINGS_DIR))

load_settings()
module.exports = {
    SETTINGS: SETTINGS
    login: login
    json_to_csv: json_to_csv
    get_digit: get_digit
}
