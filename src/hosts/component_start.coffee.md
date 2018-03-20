Ncurl -u admin:$PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state": "STARTED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/GANGLIA_MONITOR


# Ambari Start Component host

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
  The name of host to start the component to.
* `name` (string)   
  The name of component to start.



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
  console.log( err ? err.message : "Component" + options.component_name + "Started: " + status)
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
        options.component_name ?= options.name
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: component_name' unless options.component_name
        throw Error 'Required Options: hostname' unless options.hostname
        throw Error 'Required Options: cluster_name' unless options.cluster_name
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
        #"":{""
        #Kerberos Service Check","command":"KERBEROS_SERVICE_CHECK","operation_level":{"level":"CLUSTER","cluster_name":"ryba_test"}},"Requests/resource_filters":[{"service_name":"KERBEROS"}]}	
          try
            throw err if err
            response = JSON.parse response
            throw Error response.message unless statusCode is 200
            throw Error "Can not start #{options.component_name} as it is in INSTALL_FAILED state" if response['HostRoles']['state'] is 'INSTALL_FAILED'
            status = false
            console.log "component #{options.component_name} already ins STARTED state" if options.debug and  response['HostRoles']['state'] is 'STARTED'
            return do_end() if response['HostRoles']['state'] is 'STARTED'
            opts['method'] = 'PUT'
            opts.content = JSON.stringify
              RequestInfo:
                context: "Service Start #{options.component_name} (API)"
              HostRoles: state: 'STARTED'
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              error = err
              status = true unless err
              do_end()
          catch err
            error = err
            do_end()
            
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
