# User Guide
As it stands - the project is currently a VS2015 solution with two projects - A database project and a PowerShell project.
To use - deploy the database project to a SQL server of you choice.
Run the ParseLogs script and pass through or specify when prompted the path to the log files you want parsed and a connection string.
## Connection Strings / Authentication
There is a role on the Database called AddIISLogRole - the sql login will require this role.  If your web and database servers are in a domain I would recommend using windows credentials - run your script as a secheduled task using domain account with privilages on the local drive to read/rename/delete log files and in the role on the SQL database.
If your outside a domain you will need to use a local account and sql login.
## Notes on current version
There is no deletion of old rows - sql stored proc will follow which can be run as SQL job or called from scheduled task.
Will run on all files - will change to at files 2 hours  old and recommend that you rotate your IIS log files every hour so should never run on one in flight.