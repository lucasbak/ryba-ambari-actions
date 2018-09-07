
# Ambari Component Update to host

Add a host to an ambari cluster [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
The node should already exist in ambari.

* `password` (string)
  Ambari Administrator password.
* `url` (string)
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `component_name` (string)
  The name of the component to add.
* `hostname` (string)
  The name of host to add the component to.
* `properties` (object)
  The object of proeprties to put, required.


## Exemple

```js
.hosts.component_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "component_name": 'NAMENODE'
  "hostname": 'master1.metal.ryba'
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
      requests = null
      options.debug ?= false
      do_end = ->
        return callback error, status, requests if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status, requests
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: component_name' unless options.component_name
        throw Error 'Required Options: hostname' unless options.hostname
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: properties' unless options.properties
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/hosts/#{options.hostname}/host_components"
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
          try
            throw err if err
            response = JSON.parse response
            throw Error response.message unless statusCode is 200
            hostroles = response['HostRoles']
            return do_end() if hostroles.desired_state in ['INSTALLED']
            opts['method'] = 'PUT'
            opts.content = JSON.stringify options.properties
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              try
                throw err if err
                response = JSON.parse response
                requests = response['Requests']
                status = true
                do_end()
              catch err
                error = null
                do_end()
          catch err
            error = err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
