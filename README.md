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


Current (debug) output:
```
Started. ( press ^C to exit )
1527460382.450 3 RxSDR Closed 0 RxAUX Active 97 RxSDR2 Closed 0
1527460383.464 3 RxSDR Closed 0 RxAUX Active 100 RxSDR2 Closed 0
1527460384.470 3 RxSDR Closed 0 RxAUX Active 100 RxSDR2 Closed 0
1527460385.181 3 RxSDR Closed 0 RxAUX Closed 0 RxSDR2 Closed 0
1527460387.116 3 RxSDR Active 96 RxAUX Closed 0 RxSDR2 Open 8
1527460388.156 3 RxSDR Active 96 RxAUX Closed 0 RxSDR2 Open 6
1527460389.163 3 RxSDR Active 96 RxAUX Closed 0 RxSDR2 Open 6
1527460390.101 3 RxSDR Closed 0 RxAUX Closed 0 RxSDR2 Closed 0
1527460418.750 3 RxSDR Open 6 RxAUX Closed 0 RxSDR2 Active 96
1527460419.764 3 RxSDR Open 7 RxAUX Closed 0 RxSDR2 Active 96
1527460420.465 3 RxSDR Closed 0 RxAUX Closed 0 RxSDR2 Closed 0
^C
Stopped.
```
