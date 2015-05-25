# Spacewalk configuration using Vagrant, Saltstack, pgpool-II and Postgresql
This is an example of (semi)automatic configuration of [Spacewalk](https://github.com/spacewalkproject/spacewalk) *nigthly* with [Postgresql](http://www.postgresql.org) in high availability mode using [pgpool-II](http://www.pgpool.net).

The configuration is done using [Vagrant](https://www.vagrantup.com) + [Saltstack](saltstack.com)
## General setup
The setup is composed of two machines:
* `app` (`192.168.99.2`) - runs both Spacewalk and Postgresql master node
* `dbslave` (`192.168.99.3`)- runs the Postgresql slave

This is done only for the sake of simplicity. A more realistic setup would probably deploy the Postgresql master on it's own machine.

Also the pgpool setup is pretty basic. In a production setup you would probably want to have HA also for pgpool itself.

In case pgpool becomes a botleneck a better alternative would be pgbouncer for the connection pooling part and pgpool for failover.

Again, to keep things simple, SaltStack is configured in masterless mode. 
## Postgresql setup
The database useses streaming replication 
## How to get started
```sh
$ git clone https://github.com/mateiw/vagrant-spacewalk-pg
```
Start both machines:
```sh
$ vagrant up
```
Automatic provisioning is turned off by default. After the machines start, log into `app` machine and run the following as `root` (password for both root and vagrant user is `vagrant`):
```sh
# salt-call state.highstate
```
This should set up everything. 

Alternatively, if you preffer to do it step by step, do the following on the `app` machine:

Install and configure Postgresql:
```sh
# salt-call state.sls postgres
```
Generate and copy ssh keys for passwordless login (neded for the pgpool failover):
```sh
# salt-call state.sls ssh
```
Install and configure pgpool-II:
```sh
# salt-call state.sls ssh
```
And finally install Spacewalk:
```sh
# salt-call state.sls spacewalk
```
Now that the first node is up and running, log into `dbslave` and do the following:
```sh
# salt-call state.highstate
```
This should set up Postgresql and configure it as a replica of `app`.

Finally, you should have everything set up. Open in the browser https://localhost and you should be greeted by the Spacewalk GUI.

