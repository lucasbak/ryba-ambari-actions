
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
  Name of the cluster
* `hostname` (string)   
  Hostname of the server to add, required.
* `rack_info` (string|Int)   
  The rack the host belongs to, required.
  

## Exemple

```js
nikita
.hosts.rack({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "hostname": 'master1.server.com'
  "rack_info": 1
  }
}, function(err, status){
  console.log( err ? err.message : "Rack Updated: " + status)
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
        throw Error 'Required Options: rack_info' unless options.rack_info
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
          try
            throw err if err
            response = JSON.parse response
            throw Error " #{options.hostname} does not exit in ambari database " if response?.status is 404
            return do_end() if response['Hosts']['rack_info'] is options.rack_info
            opts['method'] = 'PUT'
            opts.content ?= JSON.stringify
              "Hosts":  "rack_info" : "#{options.rack_info}"
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              try
                throw err if err
                if statusCode isnt 200
                  response = JSON.parse response
                  throw Error response.message
                else
                  status = true
                  do_end()
              catch err
                error = err
                do_end()
          catch err
            error = err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
