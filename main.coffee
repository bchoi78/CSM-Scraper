get_sections = require('./src/get_sections.coffee')
get_students = require('./src/get_students.coffee')

utilities = {
    'get_all_students': get_students.run
    'get_students_max_absence': get_students.filter_by_max_absence
    'get_sections': get_sections.run
}

print_help = () ->
    console.log "
coffee main.coffee utility_name [args]\n\n

Supported utilities:\n
get_all_students [csv_dir]                      Writes all students names, emails, and attendance statuses to the given CSV file\n
get_students_max_absence [csv_dir, max]         Same as get_all_students but only for students with more than max unexcused absences\n
get_sections [csv_dir]                          Writes all section information to the given csv directory\n
    "

args = process.argv[2..]
if args.length
    utilities[args[0]].apply(this, args[1..])
else
    print_help()
