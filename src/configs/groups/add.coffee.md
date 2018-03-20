
# Ambari Configs Groups

Create ambari config groups [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, required
* `group_name` (string)   
  The config groups name, required
* `description` (string)   
  description associated to config group
* `tag` (string)   
  tag of the config groups, required
  Tha tag is wht identified uniquely on admin side the config groups
* `hosts` (string|array)   
  hosts which should belong to config group.
* `desired_configs` (object)   
  The object describing files types and properties.
  the key is the configuration_type, value are the properties.

## Exemple

```js
configs.groups({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'ryba_test',
  "group_name": "compute_worker"
  "tag": "a tag"
  "description": "yarn high compute power"
  "hosts": ['worker01.metal.ryba']
  "desired_configs": {
    "type: "hdfs-site",
    "tag": "advances hdfs site",
    "properties": {
      "datanode.dir": "[DISK]file://data/1/hdfs"
      }  
  }
  }
}, function(err, status){
  console.log( err ? err.message : "Config groups CREATED/UPDATED: " + status)
})
```

## Source Code
This functions does a single post request with desired_configs and config_group.
Hosts can be empty as the config group can be uptade with a later PUT request.

    module.exports = (options, callback) ->
      process.stdout.write "Entering config.grous.add\n" if options.debug
      error = null
      status = false
      options.debug ?= false
      options.merge ?= true
      do_end = ->
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: group_name' unless options.group_name
        throw Error 'Required Options: tag' unless options.tag
        throw Error 'Required Options: desired_configs' unless options.desired_configs
        options.desired_configs = [options.desired_configs] unless Array.isArray options.desired_configs 
        options.hosts ?= []
        options.hosts = [options.hosts] unless Array.isArray options.hosts
        options.description ?= "config group cluster: #{options.cluster_name} group #{options.group_name}"
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
        #check desired_configs keys
        for config in options.desired_configs
          for k, v of config
            throw Error "Missing config.type" unless config.type
            throw Error "Missing config.tag" unless config.tag
            throw Error "Missing config.properties" unless config.properties
            for name, value of config.properties
              config.properties[name] = value.join(',') if Array.isArray value

## Get Config Group Item
get groupname and tag at index i to check if matches options.tag and options.group_name

        do_get_config_group_item = (index, configs) ->
          config = configs[index]
          opts['method'] = 'GET'
          opts.path = config.href
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              response = JSON.parse response
              throw response.message unless parseInt(statusCode) is 200
              return do_end() if (response.ConfigGroup.group_name is options.group_name) and (response.ConfigGroup.tag is options.tag)
              ## check if the index is the arrya's length (meaning that allitems have been checked)
              index = index + 1
              if index is configs.length
                do_post_config_group()
              else
                do_get_config_group_item(index, configs)
            catch err
              error = err
              do_end()
        do_post_config_group = ->
          opts['method'] = 'POST'
          opts.path = "#{path}/config_groups"
          newConfigGroup =
            ConfigGroup: 
              cluster_name: options.cluster_name
              group_name: options.group_name
              tag: options.tag
              description: options.description
              hosts: options.hosts.map (host) -> host_name: host
              desired_configs: options.desired_configs
          opts.content = JSON.stringify newConfigGroup
          process.stdout.write "config.grous.add: post configGroup #{options.group_name}\n" if options.debug
          # opts.json = true
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              console.log parseInt(statusCode)
              throw err if err
              response = JSON.parse response
              switch parseInt(statusCode)
                when 201
                  process.stdout.write "config.grous.add: created configGroup #{options.config_name}\n" if options.debug
                  status = true
                  return do_end()
                when 409
                  status = false
                  return do_end()
                else
                  throw Error response.message
            catch err
              error = err
              do_end()
        opts['method'] = 'GET'
        opts.path = "#{path}/config_groups"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          try
            console.log parseInt(statusCode)
            throw err if err
            response = JSON.parse response
            throw response.message unless parseInt(statusCode) is 200
            if response.items.length is 0 then do_post_config_group() else  do_get_config_group_item( 0, response.items)
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
