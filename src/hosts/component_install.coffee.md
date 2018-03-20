Ncurl -u admin:$PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state": "STARTED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/GANGLIA_MONITOR


# Ambari Install Component host

Install a component's service on a host [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
The service and the node should exist

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, optional
* `hostname` (string)   
  The name of host to start the component to.
* `name` (string)   
  The name of component to start.
* `wait` (boolean)   
  Use the request Id return by install to wait until it finished. If true
the status will be true if the final state is `FINISHED`, or false if in `INSTALL_FAILED`
state. Default to false.


## Exemple

```js
.hosts.component_install({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "component_name": 'NAMENODE'
  "hostname": 'master1.metal.ryba'
  }
}, function(err, status){
  console.log( err ? err.message : "Component" + options.component_name + "Installed: " + status)
})
```

## Source Code

    module.exports = (options, callback) ->
      error = null
      status = false
      options.debug ?= false
      options.stdout ?= process.stdout
      interval = null
      do_end = ->
        clearInterval interval if interval?
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status
      try
        options.component_name ?= options.name
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: component_name' unless options.component_name
        throw Error 'Required Options: hostname' unless options.hostname
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        options.wait ?= true
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/hosts/#{options.hostname}/host_components/#{options.component_name}"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = "#{path}"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          try
            throw err if err
            response = JSON.parse response
            throw Error response.message unless statusCode is 200
            if not (response['HostRoles']['state'] is 'INIT')
              return do_end() if response['HostRoles']['state'] in ['INSTALLED','STARTED','STOPPED']
              return do_end() if response['HostRoles']['desired_state'] in ['STARTED','STOPPED']
            opts['method'] = 'PUT'
            opts.content = JSON.stringify
              RequestInfo:
                context: "Service Install #{options.component_name} (API)"
              HostRoles: state: 'INSTALLED'
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              request_id = null
              do_wait = ->
                opts.path = "/api/v1/clusters/#{options.cluster_name}/requests/#{request_id}"
                opts.method = 'GET'
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
                console.log err, statusCode, response
                throw Error response.message unless parseInt(statusCode) is 202
                response = JSON.parse response
                request_id = response['Requests']['id']  
                throw Error response.message unless statusCode is 202
                status = true
                return if options.wait then interval = setInterval do_wait, 2000 else do_end()
              catch err
                error = err
                do_end()
          catch err
            error = err
            status = false
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
