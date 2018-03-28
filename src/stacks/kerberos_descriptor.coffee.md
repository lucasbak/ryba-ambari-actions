
# Ambari Configs update

Get ambari kerberos descriptor configuration [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

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
* `cluster_name` (string)   
  The cluster name if source is set to 'COMPOSITE'   
* `source` (string)   
  can be `STACK` or `COMPOSITE`. STACK by default.
   


## Exemple

```js
stacks.kerberos_descriptor({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "stack_name": "HDP",
  "stack_version": "2.6"
  }
}, function(err, status, properties){
  console.log( err ? err.message : "Properties are: " + properties)
})
```

## Source Code

    module.exports = (options, callback) ->
      error = null
      differences = false
      options.debug ?= false
      options.source ?= 'STACK'
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
        throw Error 'Required Options: stack_name' if (not options.stack_name) and options.source is 'STACK'
        throw Error 'Required Options: stack_version' if (not options.stack_version) and options.source is 'STACK'
        throw Error 'Required Options: cluster_name' if (not options.cluster_name) and options.source is 'COMPOSITE'
        if options.stack_name
          throw Error "Unsupported Stack Name #{options.stack_name}" unless options.stack_name in ['HDP','HDF']
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = if options.source is 'STACK'
        then "/api/v1/stacks/#{options.stack_name}/versions/#{options.stack_version}/artifacts/kerberos_descriptor"
        else "/api/v1/clusters/#{options.cluster_name}/kerberos_descriptors/COMPOSITE"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = path
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          try
            throw err if err
            response = JSON.parse response
            throw Error response.message if statusCode isnt 200
            return_response = if options.source is 'STACK'
            then artifact_data: response.artifact_data
            else kerberos_descriptor:  response['KerberosDescriptor'].kerberos_descriptor
            status = true
            do_end()
          catch err
            error = err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
