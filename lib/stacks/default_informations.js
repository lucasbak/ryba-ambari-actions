// Generated by CoffeeScript 2.3.2
(function() {
  // # Ambari  Get Default Configuration for Stack

  // Request from Ambari to compute default configuration [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

  // * `password` (string)
  //   Ambari Administrator password.
  // * `url` (string)   
  //   Ambari External URL.
  // * `username` (string)
  //   Ambari Administrator username.
  // * `stack_name` (string)
  //   Thw stack name.
  // * `stack_version` (string)   
  //   The stack version of the configuration request.
  // * `installed_services` (string|array)   
  //   List of service installed to get the configuration for.   
  // * `target_services` (string|array)   
  //   List of service to compute the configuration for.   
  // * `discover` (boolean)   
  //   Discover installed services.   

  // ## Exemple

  // ```js
  // stacks.default_informations({
  //   "username": 'ambari_admin',
  //   "password": 'ambari_secret',
  //   "url": "http://ambari.server.com",
  //   "stack_version": '2.6',
  //   "services": ['HDFS','KERBEROS','YARN']
  //   }
  // }, function(err, status){
  //   console.log( err ? err.message : "Properties UPDATED: " + status)
  // })
  // ```

  // ## Source Code
  var merge, path, utils;

  module.exports = function(options, callback) {
    var differences, do_end, do_get_configuration_for_services, do_get_installed_services, err, error, hostname, i, j, len, len1, opts, path, port, ref, ref1, ref2, return_response, srv, status;
    error = null;
    differences = false;
    if (options.debug == null) {
      options.debug = false;
    }
    return_response = null;
    status = false;
    if (options.discover == null) {
      options.discover = true;
    }
    do_end = function() {
      if (callback != null) {
        return callback(error, status, return_response);
      }
      return new Promise(function(fullfil, reject) {
        if (error != null) {
          reject(error);
        }
        return fullfil(differences);
      });
    };
    try {
      if (!options.username) {
        throw Error('Required Options: username');
      }
      if (!options.password) {
        throw Error('Required Options: password');
      }
      if (!options.url) {
        throw Error('Required Options: url');
      }
      if (!(options.installed_services || options.discover)) {
        throw Error('Required Options: installed_services');
      }
      if (!options.target_services) {
        throw Error('Required Options: target_services');
      }
      if (!options.stack_name) {
        throw Error('Required Options: stack_name');
      }
      if (!options.stack_version) {
        throw Error('Required Options: stack_version');
      }
      if ((ref = options.stack_name) !== 'HDP' && ref !== 'HDF') {
        throw Error(`Unsupported Stack Name ${options.stack_name}`);
      }
      if (!Array.isArray(options.target_services)) {
        options.target_services = [options.target_services];
      }
      if (options.installed_services != null) {
        if (!Array.isArray(options.installed_services)) {
          options.installed_services = [options.installed_services];
        }
        ref1 = options.installed_services;
        for (i = 0, len = ref1.length; i < len; i++) {
          srv = ref1[i];
          if (srv !== 'KERBEROS' && srv !== 'RANGER' && srv !== 'HDFS' && srv !== 'YARN' && srv !== 'HIVE' && srv !== 'HBASE' && srv !== 'SQOOP' && srv !== 'OOZIE' && srv !== 'PIG' && srv !== 'TEZ' && srv !== 'NIFI' && srv !== 'KAFKA' && srv !== 'MAPREDUCE2' && srv !== 'ZOOKEEPER' && srv !== 'SPARK' && srv !== 'SPARK2' && srv !== 'KNOX' && srv !== 'AMBARI_METRICS' && srv !== 'LOGSEARCH' && srv !== 'ATLAS' && srv !== 'ZEPPELIN' && srv !== 'AMBARI_INFRA') {
            throw Error(`Unsupported service ${srv}`);
          }
        }
      }
      ref2 = options.target_services;
      for (j = 0, len1 = ref2.length; j < len1; j++) {
        srv = ref2[j];
        if (srv !== 'KERBEROS' && srv !== 'RANGER' && srv !== 'HDFS' && srv !== 'YARN' && srv !== 'HIVE' && srv !== 'HBASE' && srv !== 'SQOOP' && srv !== 'OOZIE' && srv !== 'PIG' && srv !== 'TEZ' && srv !== 'NIFI' && srv !== 'KAFKA' && srv !== 'MAPREDUCE2' && srv !== 'ZOOKEEPER' && srv !== 'SPARK' && srv !== 'SPARK2' && srv !== 'KNOX' && srv !== 'AMBARI_METRICS' && srv !== 'LOGSEARCH' && srv !== 'ATLAS' && srv !== 'ZEPPELIN' && srv !== 'AMBARI_INFRA') {
          throw Error(`Unsupported service ${srv}`);
        }
      }
      [hostname, port] = options.url.split("://")[1].split(':');
      if (options.sslEnabled == null) {
        options.sslEnabled = options.url.split('://')[0] === 'https';
      }
      path = `/api/v1/stacks/${options.stack_name}/versions/${options.stack_version}/services`;
      opts = {
        hostname: hostname,
        port: port,
        rejectUnauthorized: false,
        headers: utils.headers(options),
        sslEnabled: options.sslEnabled
      };
      opts['method'] = 'GET';
      // get current tag for actual config
      do_get_configuration_for_services = function() {
        var services;
        services = [];
        services.push(...options.installed_services);
        services.push(...options.target_services);
        opts.path = `${path}?StackServices/service_name.in(${services})&fields=configurations/*,configurations/dependencies/*,StackServices/config_types/*`;
        opts['method'] = 'GET';
        return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
          try {
            if (err) {
              throw err;
            }
            return_response = JSON.parse(response);
            return_response.discovered_services = options.installed_services;
            if (statusCode !== 200) {
              throw Error(response.message);
            }
            status = true;
            return do_end();
          } catch (error1) {
            err = error1;
            error = err;
            return do_end();
          }
        });
      };
      do_get_installed_services = function() {
        opts.path = `/api/v1/clusters/${options.cluster_name}/services/`;
        return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
          try {
            if (err) {
              throw err;
            }
            response = JSON.parse(response);
            if (statusCode !== 200) {
              throw Error(response.message);
            }
            options.installed_services = response.items.map(function(item) {
              return item['ServiceInfo']['service_name'];
            });
            return do_get_configuration_for_services();
          } catch (error1) {
            err = error1;
            error = err;
            return do_end();
          }
        });
      };
      if (options.discover) {
        return do_get_installed_services();
      } else {
        return do_get_configuration_for_services();
      }
    } catch (error1) {
      err = error1;
      error = err;
      return do_end();
    }
  };

  // ## Depencendies
  utils = require('../utils');

  path = require('path');

  ({merge} = require('nikita/lib/misc'));

}).call(this);
