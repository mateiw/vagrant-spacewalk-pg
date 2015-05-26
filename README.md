# Spacewalk configuration using Vagrant, Saltstack, pgpool-II and Postgresql
This is an example of (semi)automatic configuration of [Spacewalk](https://github.com/spacewalkproject/spacewalk) **nightly** with [Postgresql](http://www.postgresql.org) in high availability mode using [pgpool-II](http://www.pgpool.net).

The configuration is done using [Vagrant](https://www.vagrantup.com) + [Saltstack](saltstack.com)
## General setup
The setup is composed of two machines:
* `app` (`192.168.99.2`) - runs both Spacewalk and Postgresql master node
* `dbslave` (`192.168.99.3`) - runs the Postgresql slave

This is done only for the sake of simplicity. A more realistic setup would probably deploy the Postgresql master on it's own machine.

Also the pgpool setup is pretty basic. In a production setup you would probably want to have HA also for pgpool itself.

In case pgpool becomes a bottleneck a better alternative would be pgbouncer for the connection pooling part and pgpool for failover.

Again, to keep things simple, SaltStack is configured in masterless mode. 
## Postgresql setup
The idea is to use streaming replication (asynchronous) to keep the two database nodes in sync. 

Since Postgresql does not implement any automatic failover, this has to be done using a third party tool (pgpool-II). 

Spacewalk is configured to connect to pgpool. This way in the event of a failover, the application will not need to be reconfigured. pgpool will promote the replica and will switch over automatically.

## How to get started
```sh
$ git clone https://github.com/mateiw/vagrant-spacewalk-pg
```
#### 1. Start both machines:
```sh
$ vagrant up
```
#### 2. Setup Postresql, pgpool and Spacewalk on `app` machine
Automatic provisioning is turned off by default. After the machines start, log into `app` machine and run the following as `root` (password for both root and vagrant user is `vagrant`):
```sh
# salt-call state.highstate
```
This should set up Postresql, pgpool and Spacewalk. 

Alternatively, if you prefer to do it step by step, you can do the following on the `app` machine:

Install and configure Postgresql:
```sh
# salt-call state.sls postgres
```
Install and configure pgpool-II:
```sh
# salt-call state.sls pgpool
```
And finally install Spacewalk:
```sh
# salt-call state.sls spacewalk
```
#### 3. Setup Postresql replica on `dbslave`
Now that the first node is up and running, log into `dbslave` and do the following:
```sh
# salt-call state.highstate
```
This should set up Postgresql and configure it as a replica of `app`.
#### 4. Generate ssh keys for the failover script
The pgpool failover script needs to be able to log into `dbslave` from `app` and create the trigger file. Therefore we need to generate and copy ssh keys needed for password less login. 
This can be done only once both machines are up and the postgres user has been created.

On `app` do:
```sh
# salt-call state.sls ssh
```
#### 5. Open Spacewalk in browser
Finally, you should have everything set up. Open in the browser https://localhost and you should be greeted by the Spacewalk GUI.


