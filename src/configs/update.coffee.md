
# Ambari Configs update

Updates ambari named config using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, required
* `config_type` (string)   
  config of the name to modify example core-site, hdfs-site... required.
* `properties` (object)   
  properties to add to the configuration, required.
* `tag` (string)   
  tag of the updated config, will be computed if no provided to: 'version' + version
* `current_tag` (string)   
  the current tag of the config_type, will read from ambari's server if not provided.
* `description` (string)   
  a note describing what modifications user provides

## Exemple

```js
configs.update({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "config_type": 'hdfs-site',
  "properties": { "dfs.nameservices": "mycluster"}
  }
}, function(err, status){
  console.log( err ? err.message : "Properties UPDATED: " + status)
})
```


    module.exports = (options, callback) ->
      error = null
      differences = false
      options.debug ?= false
      do_end = ->
        return callback error, differences if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil differences
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: config_type' unless options.config_type
        throw Error 'Required Options: source or properties' unless options.source or options.properties
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        # get current tag for actual config
        get_current_version = ->
          opts.path = "#{path}?fields=Clusters/desired_configs"
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              response = JSON.parse response
              throw Error response.message if statusCode isnt 200
              desired_configs = response['Clusters']['desired_configs']
              options.stack_version ?= response['Clusters']['version']
              options.cluster_name ?= response['Clusters']['cluster_name']
              # note each configuration has two files tag and version
              # the tag is a string while the version the id as an integer
              # this id will be used to get the latest version
              if desired_configs[options.config_type]?
                options.current_version = desired_configs[options.config_type].version
                options.current_tag = desired_configs[options.config_type].tag
                return do_diff()
              options.tag ?= 'version1'
              options.version = 1
              do_update()
            catch err
              error = err
              do_end()
        do_diff = ->
          # do diff with the current config tag
          opts.path = "#{path}/configurations?type=#{options.config_type}&tag=#{options.current_tag}"
          opts['method'] = 'GET'
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              response = JSON.parse response
              throw Error response.message if statusCode isnt 200
              current_configs = response['items'].filter( (item) -> item.version is options.current_version)
              throw Error "No config found for version #{options.current_version}" unless current_configs.length is 1
              current_properties = current_configs[0].properties
              for prop, value of options.properties
                if "#{current_properties[prop]}" isnt "#{value}"
                  differences = differences||true
                  break;
              if differences then do_update() else do_end()
            catch err
              error = err
              do_end()
        do_update = ->
          try
            console.log "update #{options.config_type} with tag: #{options.tag} version:#{options.version}" if options.debug
            options.description ?= "updated config #{options.config_type}"
            options.version = parseInt(options.current_version)+1
            options.tag ?= "version#{options.version}"
            differences = true
            opts.content ?= options.content ?= JSON.stringify [
                Clusters:
                  desired_config: [
                    type: options.config_type
                    tag: options.tag
                    properties: options.properties
                    service_config_version_note: options.description
                  ]
              ]
            # opts.headers['Content-Type'] = 'application/json'
            opts.method = 'PUT'
            opts.path = "#{path}"
            utils.doRequestWithOptions opts, (err, statusCode, response) =>
              error = err
              try
                if response isnt ''
                  response = JSON.parse response
                  throw Error response.message if statusCode isnt 200
              catch err
                error = err
              finally
                do_end()
          catch err
            error = err
            do_end()
        get_current_version()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
    path = require 'path'
    
  