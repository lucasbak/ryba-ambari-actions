
# Ambari Cluster Deploy

Put Installed State to cluster in INIT State using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

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
.cluster.update({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "name": 'my_cluster',
  "data": {"provisioning_state":"INSTALLED"}
  }
}, function(err, status){
  console.log( err ? err.message : "Cluster Updated: " + status)
})
```

## Source Code

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
      error = null
      options.wait ?= true
      status = false
      options.debug ?= false
      interval = null
      do_end = ->
        clearInterval interval if interval?
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil response
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: name' unless options.name
        options.name = options.cluster_name if options.cluster_name?
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
        opts.path = "#{path}/#{options.name}/services?ServiceInfo/state=INIT"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          throw err if err
          response = JSON.parse response
          if response?.status is 404
            console.log "cluster #{options.name} not found in ambari server cluster.deploy" if options.debug
            throw Error "Cluster #{options.name} does not exist in ambari-server"
          else
            return do_end() if response.items.length == 0
            opts['method'] = 'PUT'
            opts.path = "#{path}/#{options.name}/services"
            opts.content ?= JSON.stringify
              RequestInfo:
                context: 'Installing Services API'
              Body: ServiceInfo: state: 'INSTALLED'
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              console.log opts, err, statusCode, response
              request_id = null
              do_wait = ->
                opts.path = "/api/v1/clusters/#{options.name}/requests/#{request_id}"
                opts.method = 'GET'
                @log? message: "Wait Request id #{request_id}", level: 'INFO', module: 'ryba-ambari-actions/cluster/deploy'
                utils.doRequestWithOptions opts, (err, statusCode, response) ->
                  try
                    throw err if err
                    response = JSON.parse response
                    throw Error response.message unless statusCode is 200
                    if (response['Requests']['request_status'] is 'COMPLETED')
                      status = true
                      do_end()
                  catch err
                    error = err
                    do_end()
              try
                throw err if err
                throw Error response.message unless parseInt(statusCode) in [200,202]
                return do_end() if parseInt(statusCode) is 200
                response = JSON.parse response
                request_id = response['Requests']['id']  
                @log? message: "Deploy Cluster Service #{options.component_name} Accepted with Request id #{request_id}", level: 'INFO', module: 'ryba-ambari-actions/cluster/deploy'
                throw Error response.message unless statusCode is 202
                status = true
                return if options.wait then interval = setInterval do_wait, 2000 else do_end()
              catch err
                error = err
                do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
