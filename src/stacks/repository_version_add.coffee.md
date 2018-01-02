

# Ambari repository version add

Add a repository version for given stack [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
The stack should exist as the target version

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, optional
* `stack_name` (string)   
  name of the stack, required.
* `stack_version` (string)   
  version of the stack, required.  
* `stack_name` (string)   
  name of the stack, required.
* `repository_version` (string)   
  Fulle version of the target repository, required.  
* `display_name` (string)   
  display strong for the full version, required.  
* `repositories` (object)
    an object representing the repositories.
    the key should be the operating system
    the value should be an object containing all os' related repositories

  
## Exemple

```js
nikita
.stacks.repository_version_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'my_cluster'
  "name": 'HDFS'
  }
}, function(err, status){
  console.log( err ? err.message : "Node Added To Cluster: " + status)
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
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: stack_name' unless options.stack_name
        throw Error 'Required Options: stack_version' unless options.stack_version
        throw Error 'Required Options: display_name' unless options.display_name
        throw Error 'Required Options: repository_version' unless options.repository_version
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: repositories' unless options.repositories
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/stacks/#{options.stack_name}/versions/#{options.stack_version}/repository_versions/"
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
            throw Error response.message if parseInt(statusCode) isnt 200
            #if the display name already exist, we consider its an update set metho to PUT
            do_check_current = (index, items, cb)->
              return cb null, false if items.length is 0
              item = items[index]
              opts['method'] = 'GET'
              opts.path = item.href
              opts.json = true
              utils.doRequestWithOptions opts, (err, statusCode, result) ->
                try
                  throw err if err
                  response = result
                  # check display name already here
                  update = false
                  update  = (response['RepositoryVersions'].display_name is options.display_name) || true
                  index = index + 1
                  if (index is items.length) or update
                    cb null, update
                  else
                    do_check_current index, items, cb
                catch err
                  cb err
            do_check_current 0, response.items, (err, update) ->
              try
                opts.json = false
                opts.headers = utils.headers options
                throw err if err
                opts.content  =
                  RepositoryVersions:
                    repository_version: options.repository_version
                    display_name: options.display_name
                  operating_systems: []
                #inspired from https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/repository-version-resources.md
                # TODO repository base url validation
                added = false
                for os_config in options.repositories
                  throw Error 'Os type not supported' unless os_config.os_type in ['redhat6', 'redhat7', 'centos6', 'centos7']
                  if opts.content.operating_systems.length > 0
                    for os in opts.content.operating_systems
                      if os.OperatingSystems.os_type is os_config.os_type
                        os.repositories.push
                          Repositories:
                            repo_id: os_config.repo_id
                            repo_name: os_config.repo_name
                            base_url: os_config.base_url
                        added = true
                      if not added#os type not added yet
                        opts.content.operating_systems.push
                          OperatingSystems:
                            os_type: os_config.os_type
                          repositories: [
                            Repositories:
                              repo_id: os_config.repo_id
                              repo_name: os_config.repo_name
                              base_url: os_config.base_url
                          ]
                  else
                    opts.content.operating_systems.push
                      OperatingSystems:
                        os_type: os_config.os_type
                      repositories: [
                        Repositories:
                          repo_id: os_config.repo_id
                          repo_name: os_config.repo_name
                          base_url: os_config.base_url
                      ]
                # already_exist = false
                # for repository in response.items
                #   if (repository.stack_name is options.stack_name) and (repository.stack_version is options.stack_version)
                #     already_exist = true
                #     href = item.href
                #     break;
                # return do_end() if already_exist
                opts['method'] = if update then 'PUT' else 'POST'
                opts.content = JSON.stringify opts.content
                utils.doRequestWithOptions opts, (err, statusCode, response) ->
                  try
                    throw err if err
                    response = JSON.parse response if response isnt ''
                    throw Error response.message if parseInt(statusCode) not in [200, 201]
                    status = true
                    do_end()
                  catch err
                    error = err
                    do_end()
              catch err
                error = err
                console.log 'catched', err
                do_end()
          catch err
            error = err
            console.log 'catched', err
            do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
