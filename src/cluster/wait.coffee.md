
# Ambari Cluster Add

Create a cluster using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `name` (string)   
  Name of the cluster.
* `version` (string)   
  Version of the cluster, required.
* `security_type` (string)   
  NONE or KERBEROS. default to NONE.

## Exemple

```js
nikita
.cluster.add({
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

## Source Code

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
      error = null
      status = false
      options.debug ?= false
      options.security_type ?= 'NONE'
      interval = null
      options.timeout ?= 10*60*60*1000
      do_end = ->
        clearInterval interval if interval?
        status = true unless error?
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil response
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: name' unless options.name
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters"
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
              waited = waited + 1000
              response = JSON.parse response
              @log? message: "Ok: Cluster available  name:#{options.name}", level: 'INFO', module: 'ryba-ambari-actions/cluster/wait' if parseInt(statusCode) is 200
              @log? message: "Clearing Interval", level: 'INFO', module: 'ryba-ambari-actions/cluster/wait' if parseInt(statusCode) is 200
              clearInterval interval if interval? and ((parseInt(statusCode) is 200) or (waited > options.timeout))
              return do_end() if parseInt(statusCode) is 200
              return do_end() if waited > options.timeout
              @log? message: "Cluster Not Available name:#{options.name}", level: 'INFO', module: 'ryba-ambari-actions/cluster/wait'
              throw Error response.message if parseInt(statusCode) not in [200, 404]
            catch err
              error = err
        @log? message: "Set Wait Interval 1000ms", level: 'INFO', module: 'ryba-ambari-actions/cluster/wait'
        interval = setInterval do_request, 1000
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
