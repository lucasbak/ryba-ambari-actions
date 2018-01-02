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
        error = null
        statusCode = null
        response = null
        error = Error 'Missin hostname' unless options.hostname?
        error = Error 'Missing port' unless options.port?
        error = Error 'Missing method' unless options.method?
        error = Error 'Invalid method' unless options.method in ['GET','POST','PUT','DELETE']
        error = Error 'Mssing path' unless options.path?
        do_end = ->
          callback error, statusCode, response if callback?
          new Promise (fullfil, reject) ->
            reject error if error?
            fullfil statusCode, response
        do_request = ->
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
              if typeof options.content is 'string'
                opts.headers['Content-Length'] ?= options.content.length
            http_maker = if options.sslEnabled then https else http
            request = http_maker.request opts, (res) ->
              res.on 'data', (data) -> response_object+= data
              res.on 'end', ->
                try
                  response_object = JSON.parse response_object if options.json
                  error = null
                  # if res.statusCode not in [200,201]
                  #   response_object = JSON.parse response_object
                  #   error = Error "Error: #{response_object.message}"
                  statusCode  = res.statusCode
                  response = response_object
                  do_end()
                catch err
                  error = err
                  do_end()
              res.on 'error', (err) ->
                error  = err
                do_end()
            if options.content?
              request.on 'error', (err) ->
                error = err
                do_end()
              request.write options.content
              request.end()
            else
              request.on 'error', (err) ->
                error = err
                do_end()
              request.end()
          catch err
            error = err
            do_end()
        do_request()


## Dependencies

    http = require 'http'
    https = require 'https'
