[![Build Status](https://secure.travis-ci.org/lucasbak/ryba-ambari-actions.svg)](http://travis-ci.org/ucasbak/ryba-ambari-actions)

# Ryba Ambari Actions

Gather a set of functions to communicate with [Apche Ambari](https://ambari.apache.org/) [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
It can be used with [nikita](https://github.com/adaltas/node-nikita)

It has been built for Node.js and is written in CoffeeScript.

## Usage

Example usage can be found in test:

- plain javascript in callback method
```javascript
configs.get({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "config_type": 'hdfs-site'
  }
}, function(err, status, properties){
  console.log( err ? err.message : "Properties are: " + properties)
})
```

- coffeescript example with as a nikita action

```coffee
@ambari.hosts.component_wait
  url: 'http://ambari.server.com'
  username: 'admin_admin'
  password: 'ambari_secret'
  cluster_name: 'my_cluster'
  component_name: 'HDFS_CLIENT'
  hostname: 'agent.server.com'

```

## Functions

* cluster
  - add
  - delete
  - node_add
  - node_delete
  - persist
  - provisioning_state
  - update
  - wait

* configs
  - groups
   - add
   - delete
  - get
  - list
  - set_default
  - update

* hosts
 - add
 - component_add
 - component_install
 - component_start
 - component_status
 - component_stop
 - component_update
 - component_wait
 - delete
 - rack

* kerberos
  * descriptor
    - update

* services
  - add
  - component_add
  - delete
  - wait

* stacks
  - default_informations
  - kerberos_descriptor
  - repository_version_add
  - vdf_add
  