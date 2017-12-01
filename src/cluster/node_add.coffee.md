
# Ambari register node for Cluster

Add a host to an ambari cluster [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
The node should already exist in ambari.

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, optional
* `hostname` (string)   
  Hostname of the server to add, required.

## Exemple

```js
nikita
.cluster.node_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'my_cluster'
  "hostname": 'server1.server.com'
  }
}, function(err, status){
  console.log( err ? err.message : "Node Added To Cluster: " + status)
})
```

## Source Code

    module.exports = (options, callback) ->
      error = null
      status = false
      options.debug ?= false
      do_end = ->
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: hostname' unless options.hostname
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/hosts"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = "#{path}/#{options.hostname}"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          throw err if err
          response = JSON.parse response
          if response?.status is 404
            console.log "host #{options.hostname} not found in ambari server cluster.node_add" if options.debug
            opts['method'] = 'POST'
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              throw err if err
              status = true
              do_end()
          else
            status = false
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
