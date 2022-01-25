# perl-App-Prove-Remote
Prove wrapper designed for executing tests from your local host on remote hosts

INSTALLING
----------
```
cpanm -i -n Net::OpenSSH Getopt::Long App::Prove
```
-n is reccomended as otherwise Net::OpenSSH runs tests that try to SSH into localhost.

Copy bin/rprove to a directory in your $PATH

RUNNING THE TESTS
-----------------
rprove -h some.test.host test1.t test2.t ...

See POD in rprove itself for more advanced usage.

TROUBLESHOOTING
---------------

Help! I can't connect!
Please check your OpenSSH client config, as this is used by default.
If it is setup correctly for the host you wish to connect to, everything will "just work".
