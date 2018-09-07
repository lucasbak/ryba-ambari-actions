
# Ambari Wait Service Created

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
* `name` (string)
  name of the service, required.
* `timeout` (string)
  timeout in millisecond to wait, default to 10 mins.


## Exemple

```js
nikita
.services.add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'my_cluster'
  "name": 'HDFS'
  }
}, function(err, status){
  console.log( err ? err.message : "Node Added To Cluster: " + status)
})
```

## Source Code

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
      error = null
      status = false
      options.debug ?= false
      interval = null
      options.timeout ?= 10*60*60*1000
      do_end = ->
        clearInterval(interval)
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: name' unless options.name
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/services"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = "#{path}/#{options.name}"
        waited = 0
        do_request = ->
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
              try
                throw err if err
                waited = waited + 2000
                response = JSON.parse response
                return do_end() if parseInt(statusCode) is 200
                return do_end() if waited > options.timeout
                throw Error response.message if parseInt(statusCode) not in [200, 404]
              catch err
                error = err
        interval = setInterval do_request, 2000
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
