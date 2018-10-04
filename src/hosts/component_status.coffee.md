Ncurl -u admin:$PASSWORD -i -H 'X-Requested-By: ambari' -X PUT -d '{"HostRoles": {"state": "STARTED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/hosts/NEW_HOST_ADDED/host_components/GANGLIA_MONITOR


# Ambari Wait Component Status

Wait until a component reahes the status on a host [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
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
  alias  on component_name option.
* `component_name` (string)   
  The name of component to start. Mandatory
* `status` (string)   
  Component's state. Mandatory
* `timeout` (string)
  timeout in millisecond to wait, default to 10 mins.

## Exemple

```js
.hosts.component_status({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "component_name": 'NAMENODE'
  "status": "STARTED"
  "hostname": 'master1.metal.ryba'
  }
}, function(err, status){
  console.log( err ? err.message : "Component" + options.component_name + "Waited: " + status)
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
        throw Error 'Required Options: status' unless options.status
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
        waited = 0
        do_request = ->
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              response = JSON.parse response
              throw Error response.message if parseInt(statusCode) not in [200, 404]
              switch parseInt(statusCode)
                when 200
                  status = switch response['HostRoles']['state']
                    when 'STARTED' then true
                    when 'INSTALLED' then false
                    else false
                else
                  status = false
              do_end()
            catch err
              error = err
              do_end()
        do_request()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
