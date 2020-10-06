# How to use
You can generate whole DDL directory or single tables. If u want generate single ddl, u need to create ExDDL folder in root and copy ddl into ExDDL folder. While running command you have to put -x in command.

Invoke-GenCWIReport
-a => All (insert, update, delete etc.)
-s => only select (basicly just view)
-i => only insert
-u => only update
-d => only delete
-da => only deleteAll
-im => only import

-sl => SingleLog - only one log table for all reports
-ml => MultiLog - each table has own log table

-x => excluded - will generate only ddl in ExDDL folder

Example:
Invoke-GenCWIReport -a -ml -x -verbose
