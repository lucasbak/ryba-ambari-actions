
# Ambari Get Default Configuration for Service(s)

This module wraps `ryba-ambari-actions/services/default_informations` function
to provide default configuration per services based on cluster layout.

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name`   
  The target cluster.
* `stack_name` (string)
  Thw stack name.
* `stack_version` (string)   
  The stack version of the configuration request.
* `service` (string)   
  Service to update the kerberos_descriptor configuration.   
* `component` (string)
  The component of the service to update configuration about.   
* `identities` (string|array)   
  The identities object(s) to update, inside service'component configuration.   
  note name key is mandatory inside an identity object   
* `source` (string)
  The source the default configuration is read from.   


## Exemple

```js
kerberos.descriptor.update({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "stack_version": '2.6',
  "stack_name: "HDP",
  "cluster_name": "rybatest",
  "service": "HDFS",
  "component": "NAMENODE",
  "identities": {
    "keytab": {
        "configuration": "hadoop-env/hdfs_user_keytab",
        "file": "${keytab_dir}/hdfs.headless.keytab",
        "group": {
          "access": "",
          "name": "${cluster-env/user_group}"
        },
        "owner": {
          "access": "r",
          "name": "${hadoop-env/hdfs_user}"
        }
      },
      "name": "hdfs",
      "principal": {
        "configuration": "hadoop-env/hdfs_principal_name",
        "local_username": "${hadoop-env/hdfs_user}",
        "type": "user",
        "value": "${hadoop-env/hdfs_user}${principal_suffix}@${realm}"
      }
    }
  }
}, function(err, status){
  console.log( err ? err.message : "Properties UPDATED: " + status)
})
```

## Source Code
Will iterate through each identities object of the service'component, and will merge
it's value with the one given in option.

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
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
        throw Error 'Required Options: stack_name' if (not options.stack_name) and options.source is 'STACK'
        throw Error 'Required Options: stack_version' if (not options.stack_version) and options.source is 'STACK'
        throw Error 'Required Options: cluster_name' if (not options.cluster_name) and options.source is 'COMPOSITE'
        if options.stack_name
          throw Error "Unsupported Stack Name #{options.stack_name}" unless options.stack_name in ['HDP','HDF']
        # throw Error 'Required Options: service' unless options.service
        # throw Error 'Required Options: component' unless options.component
        throw Error 'Required Options: identities' unless options.identities
        options.identities = [options.identities] unless Array.isArray options.identities
        get_kerberos_descriptor options, (err, status, informations) ->
          try
            throw err if err
            options.artifact_data ?= if options.source is 'STACK'
            then  informations.artifact_data else informations.kerberos_descriptor
            # preapre the request body and headers
            [hostname,port] = options.url.split("://")[1].split(':')
            options.sslEnabled ?= options.url.split('://')[0] is 'https'
            path = "/api/v1/clusters/#{options.cluster_name}/artifacts/kerberos_descriptor"
            opts = {
              hostname: hostname
              port: port
              rejectUnauthorized: false
              headers: utils.headers options
              sslEnabled: options.sslEnabled
            }
            opts.path = path
            opts['method'] = 'GET'
            do_request = ->
              utils.doRequestWithOptions opts, (err, statusCode, response) ->
                try
                  throw err if err
                  switch parseInt(statusCode)
                    when 200 then opts['method'] = 'PUT'
                    when 404 then opts['method'] = 'POST'
                    else                    
                      response = JSON.parse response
                      throw Error response.message
                  opts.content = JSON.stringify
                    artifact_data: options.artifact_data
                  utils.doRequestWithOptions opts, (err, statusCode, response) ->
                    try
                      throw err if err
                      if statusCode not in [200,201]
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
            # prepare the cluster global level configuration function
            do_cluster_level_configuration = ->
              for global_identity , gl_id in options.artifact_data.identities
                for  identity in options.identities
                  continue unless global_identity.name is identity.name
                  options.artifact_data.identities[gl_id] = identity
                  global_identity = identity
              do_request()
            # prepare the service/component global level configuration function
            do_service_or_component_level_configuration = ->
              for service, k_srv_id in options.artifact_data.services
                continue unless service.name is options.service
                if options.component
                  for component, k_co_id in service.components
                    continue unless component.name is options.component
                    for component_identity , k_identity_id in component.identities
                      for  identity in options.identities
                        continue unless component_identity.name is identity.name
                        options.artifact_data.services[k_srv_id].components[k_co_id].identities[k_identity_id] = identity
                    do_request()
                else
                  for service_identity, k_id in service.identities
                    for identity in options.identities
                      continue unless service_identity.name is identity.name
                      options.artifact_data.services[k_srv_id].identities[k_id] = identity
                  do_request()
            if options.service then do_service_or_component_level_configuration() else do_cluster_level_configuration()
          catch err
            error = err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../../utils'
    path = require 'path'
    {merge} = require 'nikita/lib/misc'
    get_kerberos_descriptor = require '../../stacks/kerberos_descriptor'
