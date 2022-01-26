
# Ambari  Get Default Configuration for Stack

Request from Ambari to compute default configuration [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `stack_name` (string)
  Thw stack name.
* `stack_version` (string)   
  The stack version of the configuration request.
* `installed_services` (string|array)   
  List of service installed to get the configuration for.   
* `target_services` (string|array)   
  List of service to compute the configuration for.   
* `discover` (boolean)   
  Discover installed services.   
  
## Exemple

```js
stacks.default_informations({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "stack_version": '2.6',
  "services": ['HDFS','KERBEROS','YARN']
  }
}, function(err, status){
  console.log( err ? err.message : "Properties UPDATED: " + status)
})
```

## Source Code

    module.exports = (options, callback) ->
      error = null
      differences = false
      options.debug ?= false
      return_response = null
      status = false
      options.discover ?= true
      do_end = ->
        return callback error, status, return_response if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil differences
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: installed_services' unless options.installed_services or options.discover
        throw Error 'Required Options: target_services' unless options.target_services
        throw Error 'Required Options: stack_name' unless options.stack_name
        throw Error 'Required Options: stack_version' unless options.stack_version
        throw Error "Unsupported Stack Name #{options.stack_name}" unless options.stack_name in ['HDP','HDF','ODP']
        options.target_services = [options.target_services] unless Array.isArray options.target_services
        if options.installed_services?
          options.installed_services = [options.installed_services] unless Array.isArray options.installed_services
          for srv in options.installed_services
            throw Error "Unsupported service #{srv}" unless srv in [
              'DRUID','KERBEROS','RANGER','RANGER_KMS','HDFS','YARN','HIVE','HBASE','SQOOP','OOZIE','PIG','TEZ','NIFI','KAFKA','MAPREDUCE2','ZOOKEEPER', 'SPARK', 'SPARK2', 'KNOX', 'AMBARI_METRICS', 'LOGSEARCH', 'ATLAS', 'ZEPPELIN', 'AMBARI_INFRA', 'SMARTSENSE','STORM'
            ]
        for srv in options.target_services
          throw Error "Unsupported service #{srv}" unless srv in [
            'DRUID','KERBEROS','RANGER','RANGER_KMS','HDFS','YARN','HIVE','HBASE','SQOOP','OOZIE','PIG','TEZ','NIFI','KAFKA','MAPREDUCE2','ZOOKEEPER', 'SPARK', 'SPARK2', 'KNOX', 'AMBARI_METRICS', 'LOGSEARCH', 'ATLAS', 'ZEPPELIN', 'AMBARI_INFRA', 'SMARTSENSE','STORM'
          ]
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/stacks/#{options.stack_name}/versions/#{options.stack_version}/services"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        # get current tag for actual config
        do_get_configuration_for_services = ->
          services = []
          services.push options.installed_services...
          services.push options.target_services...
          opts.path = "#{path}?StackServices/service_name.in(#{services})&fields=configurations/*,configurations/dependencies/*,StackServices/config_types/*"
          opts['method'] = 'GET'
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              return_response = JSON.parse response
              return_response.discovered_services = options.installed_services
              throw Error response.message if statusCode isnt 200
              status = true
              do_end()
            catch err
              error = err
              do_end()
        do_get_installed_services = ->
          opts.path = "/api/v1/clusters/#{options.cluster_name}/services/"
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              response = JSON.parse response
              throw Error response.message if statusCode isnt 200
              options.installed_services = response.items.map (item) -> item['ServiceInfo']['service_name']
              do_get_configuration_for_services()
            catch err
              error = err
              do_end()
        if options.discover then do_get_installed_services() else do_get_configuration_for_services()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
    path = require 'path'
