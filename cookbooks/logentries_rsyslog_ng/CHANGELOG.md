# 0.0.7

* Add: action names
* Add: disk assisted queues for actions
* Add: no tls mode for testing
* Add: testing that send data to logentries

# 0.0.6

* Fix: update cookbook to follow logentries API changes

# 0.0.5

* Add: log_owner and log_group attributes. If log file doesn't exist
  logentries LWRP can use those attribues to create log file with
  specific owner and group
* Add: test-kitchen basic config/setup for manual testing.

# 0.0.4

* Add: rsyslog_ruleset attribute to be able to place remote logging to
non-default rsyslog rulesets

# 0.0.3

* Fix: several typos/errors in a code

# 0.0.2

* Add: creating logfile directories if they are not created.

# 0.0.1

* Initial version of cookbook.
* Add: log :add action that creates logentries token/entries and rsyslog config files.
