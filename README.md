# pty2sql
SVXLINK STATE_PTY to MySQL

Work in progress

Reads the STATE_PTY file and stores the information into a (remote) MySQL database.

This might be a bit slower as the eventsource.pl from PE1CHL to show data on webpage as it used MySQL.
Though it does not have a JSON crossdomain problem :)

SQL:
Table pty - Stores each single receiver for history processing (Like last sql open at receiver xx on date yy)
Table live - For live stats on a web page

TODO:
systemd file to run as service
error checks
php web interface to read out database (Read database with Jquery/AJAX).
and maybe more
