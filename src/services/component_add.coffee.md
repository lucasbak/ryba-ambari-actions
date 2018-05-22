
# Ambari Component to service

Add a component to an existing component [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, optional
* `component_name` (string)   
  The name of the component to add.
* `service_name` (string)   
  The name of the service the component belongs to.
* `hostname` (string)   
  The hostname where the component is installed, required.

## Exemple

```js
.services.component_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'my_cluster'
  "component_name": 'NAMENODE'
  "service_name": 'HDFS'
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
        throw Error 'Required Options: component_name' unless options.component_name
        throw Error 'Required Options: service_name' unless options.service_name
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/services/#{options.service_name}/components"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = "#{path}/#{options.component_name}"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          throw err if err
          response = JSON.parse response
          if response?.status is 404
            console.log "component_name #{options.component_name} not found in ambari server services.component_name" if options.debug
            opts['method'] = 'POST'
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              try
                throw err if err
                if parseInt(statusCode) isnt 201
                  response = JSON.parse response
                  throw Error response.message 
                status = true
                do_end()
              catch err
                error = err
                do_end()
          else
            status = false
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
