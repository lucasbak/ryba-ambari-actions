'use strict'

    module.exports =
      headers: (options) ->
        headers = 
          'X-Requested-By': 'ambari'
          "cache-control": "no-cache"
        if options.username and options.password
          headers['Authorization'] ?= 'Basic ' + new Buffer(options.username + ':' + options.password).toString('base64');
        headers
      doRequestWithOptions: (options, callback) ->
        throw Error 'Missin hostname' unless options.hostname?
        throw Error 'Missing port' unless options.port?
        throw Error 'Missing method' unless options.method?
        throw Error 'Invalid method' unless options.method in ['GET','POST','PUT','DELETE']
        throw Error 'Mssing path' unless options.path?
        if callback?
          try
            opts = {
              hostname: options.hostname
              port: options.port
              path: "#{options.path}"
              method: options.method
              headers: options.headers
            }
            response_object = ''
            #ssl
            if options.sslEnabled
              opts['rejectUnauthorized'] = options.rejectUnauthorized
            #headers
            opts.headers ?= {}
            if options.json
              opts.headers['Content-Type'] ?= 'application/json'
            if options.content?
              opts.headers['Content-Length'] ?= options.content.length
            http_maker = if options.sslEnabled then https else http
            console.log opts
            request = http_maker.request opts, (res) ->
              res.on 'data', (data) -> response_object+= data
              res.on 'end', ->
                try
                  console.log response_object
                  response_object = JSON.parse response_object if options.json
                  error = null
                  # if res.statusCode not in [200,201]
                  #   response_object = JSON.parse response_object
                  #   error = Error "Error: #{response_object.message}" 
                  return callback error, res.statusCode, response_object
                catch err
                  return callback err
              res.on 'error', (error) -> callback error
            if options.content?
              request.on 'error', (error ) -> return callback error
              request.write options.content
              request.end()
            else
              request.on 'error', (error) ->
                return callback error
              request.end()
          catch err
            return callback err
        else
          new Promise (fullfil, reject) ->
            try
              opts = {
                hostname: options.hostname
                port: options.port
                path: options.path
                method: options.method
                }
              response_object = ''
              #ssl
              if options.sslEnabled
                opts['rejectUnauthorized'] = options.rejectUnauthorized
              #headers
              opts.headers ?= {}
              if options.json
                opts.headers['Content-Type'] ?= 'application/json'
              if options.content
                opts.headers['Content-Length'] ?= options.content.length
              http_maker = if options.sslEnabled then https else http
              request = http_maker.request opts, (res) ->
                res.on 'data', (data) -> response_object+= data;
                res.on 'end', ->
                  try
                    response_object = JSON.parse response_object if options.json
                    fullfil res.statusCode, response_object
                  catch err
                    reject err
                res.on 'error', (error) ->
                  reject error
              if options.content?
                request.on 'error', (error ) -> return reject error
                request.write options.content
                request.end()
              else
                request.on 'error', (error ) ->
                  reject error
                request.end()
            catch err
              reject err


## Dependencies

    http = require 'http'
    https = require 'https'
