
# Ambari Get Default Configuration for Service(s)

This module wraps `ryba-ambari-actions/services/default_informations` function
to provide default configuration per services based on cluster layout.

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
  List of service that should be installed on cluster.   
* `target_services` (string|array)   
  List of service to compute the configuration for.   

## Exemple

```js
configs.get_default({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "stack_version": '2.6',
  "services": ['HDFS','KERBEROS','YARN']
  "target_services": ['PIG']
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
      response = null
      status = false
      default_configuration_request = {}
      do_end = ->
        return callback error, status, response if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil differences
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: installed_services' unless options.installed_services or options.discover
        throw Error 'Required Options: target_services' unless options.target_services
        throw Error 'Required Options: stack_name' unless options.stack_name
        throw Error 'Required Options: stack_version' unless options.stack_version
        options.target_services = [options.target_services] unless Array.isArray options.target_services
        if options.installed_services?
          options.installed_services = [options.installed_services] unless Array.isArray options.installed_services
          for srv in options.installed_services
            throw Error "Unsupported service #{srv}" unless srv in [
              'KERBEROS','RANGER','HDFS','YARN','HIVE','HBASE','SQOOP','OOZIE','PIG','TEZ','NIFI','KAFKA','MAPREDUCE2','ZOOKEEPER', 'SPARK', 'SPARK2'
            ]
        for srv in options.target_services
          throw Error "Unsupported service #{srv}" unless srv in [
            'KERBEROS','RANGER','HDFS','YARN','HIVE','HBASE','SQOOP','OOZIE','PIG','TEZ','NIFI','KAFKA','MAPREDUCE2','ZOOKEEPER', 'SPARK', 'SPARK2'
          ]
        services = []
        services.push options.target_services...
        action_default_informations options, (err, status, informations) ->
          try
            throw err if err
            options.installed_services ?= informations.discovered_services if options.discover
            services.push options.installed_services...
            #loog through ieach service to get information
            for service in services
              default_configuration_request[service] ?= {}
              for srv in informations.items
                #compare service_name, stack_name and stack_version
                continue unless ("#{srv['StackServices'].service_name}" is "#{service}") and ("#{srv['StackServices'].stack_name}" is "#{options.stack_name}") and ("#{srv['StackServices'].stack_version}" is "#{options.stack_version}")
                for config_type_name, model of srv['StackServices'].config_types
                  console.log "discover config type #{config_type_name}" if options.debug
                  default_configuration_request[service][config_type_name] ?= {}
                  # for performance issue we do not loop through each properties to populate config type
                  # because the loop would be done for each configuration type
                  # so we just record the config-type-name and then iterate only once
                throw Error "No config type found in Ambari for service #{service}" if Object.keys(default_configuration_request[service]).length is 0
                # console.log srv.configurations
                for configuration in srv.configurations
                  # console.log configuration.href
                  console.log "comparing property #{configuration['StackConfigurations'].property_name}" if options.debug
                  config_type = configuration['StackConfigurations']['type'].split('.')[0]
                  console.log "- config type is #{config_type}" if options.debug
                  property_name = "#{configuration['StackConfigurations']['property_name']}"
                  default_configuration_request[service][config_type] ?= {}
                  default_configuration_request[service][config_type]["#{property_name}"] ?= configuration['StackConfigurations']['property_value']
            do_update_service_config = (index, target_services) ->
              service = target_services[index]
              do_update_service_config_type = (index_config, configs) ->
                config_type = configs[index_config]
                properties = default_configuration_request[service][config_type]
                options.config_type = config_type
                options.properties = properties
                #merge options bases on options.configurations object
                if options.configurations?[config_type]?
                  for k,v of options.properties
                    properties[k] = options.configurations[config_type][k]
                  for k,v of options.configurations[config_type]
                    properties[k] = options.configurations[config_type][k]
                action_config_update options, (err, done) ->
                  status = status || done
                  if err
                    error = err
                    do_end()
                  else
                    index_config = index_config + 1
                    #check if all type are done for a service
                    if index_config is configs.length
                      index = index + 1
                      #check if all target_services are done
                      if index is target_services.length
                        do_end()
                      else
                        do_update_service_config index, target_services
                    else
                      do_update_service_config_type index_config, configs
              do_update_service_config_type 0, Object.keys default_configuration_request[service]
            do_update_service_config 0, options.target_services
          catch err
            error = err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
    path = require 'path'
    {merge} = require 'nikita/lib/misc'
    action_default_informations = require '../stacks/default_informations'
    action_config_update = require './update'
