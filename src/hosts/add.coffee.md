
# Ambari Hosts Add

Create host using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
if host 

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
.cluster.add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "hostname": 'master1.server.com'
  }
}, function(err, status){
  console.log( err ? err.message : "Policy Created: " + status)
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
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/hosts"
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
            console.log "host #{options.hostname} not found in ambari server host.add" if options.debug
            opts['method'] = 'POST'
            opts.content ?= ''
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
