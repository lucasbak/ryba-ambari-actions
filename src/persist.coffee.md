
# Persist

Persist Ambari Cluster resource using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `name` (string)   
  Name of the cluster.

## Exemple

```js
nikita
.cluster_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "name": 'my_cluster'
  "version": 'HDP-2.5.3'
  }
}, function(err, status){
  console.log( err ? err.message : "Policy Created: " + status)
})
```
#Handles: PUT

    module.exports = (options, callback) ->
      error = null
      status = false
      options.debug ?= false
      do_end = ->
        console.log error, status, callback?
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil response
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/persist"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
          content: "{ \"CLUSTER_CURRENT_STATUS\": \"{\\\"clusterState\\\":\\\"CLUSTER_STARTED_5\\\"}\" }"
        }
        opts['method'] = 'POST'
        opts.json = false
        opts.path = "#{path}"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          throw err if err
          if statusCode isnt 202
            response_object = JSON.parse response
            error = Error "Error: #{response_object.message}"
            throw error
          else
            status = true
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require './utils'
