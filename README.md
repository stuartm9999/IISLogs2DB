# Project Description
Powershell script to parse multiple IIS log files from multiple servers to a SQL server database.
This project provides a power shell script and associated SQL (Schema + stored procs) to parse IIS logs from multiple servers to a database.
Database file partitioning (thanks to [@j_mcmullan](https://twitter.com/j_mcmullan) should mean it can efficiently manage huge amounts of data.
Thanks to [@amogram](https://twitter.com/amogram) for contributing to the script and the scema definition.
There is an MS tool that does this - [Log Parser](https://www.iis.net/downloads/community/2010/04/log-parser-22) that you might want to take a look at.
We were looking at a solution that:
* didn't involve installing something big on the web servers* allowed use of strongly typed stored procedures for data transfer
* would support multiple servers and large amounts of data
(We were looking at using this on a client who is pretty security conscious, as am I, and likes to abide with [OWASP Secure Coding Practices](OWASP Secure Coding Practices)(https___www.owasp.org_images_0_08_OWASP_SCP_Quick_Reference_Guide_v2.pdf), and who wouldn't, that states "Use strongly typed parameterized queries " in its database security section.## Done* Schema and stored procedures* Tested with a lot of .log files## TODO* Implement portioning and indexing on the Log table* Describe how to install/create Downloads.* Process to delete old log entries* Modify to only parse old files so wont interfere with files in flight.

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
