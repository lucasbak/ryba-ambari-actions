
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  persist = require '../src/cluster/persist'
  update = require '../src/configs/update'
  nikita = require('nikita')()

  
  describe 'cluster', ->
      
    it 'error no cluster name', (done) ->
      options = Object.assign {}, config.options
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      update options, (err) ->
        err.message.should.eql 'Required Options: cluster_name'
        done()

    it 'error no version provided', (done) ->
      options = Object.assign {}, config.options
      options.cluster_name = "ryba_test"
      options.properties =
        'dfs.nameservices': 'ryba_test'
      update options, (err) ->
        err.message.should.eql 'Required Options: config_type'
        done()

    it 'error no properties provided', (done) ->
      options = Object.assign {}, config.options
      options.cluster_name = "ryba_test"
      options.config_type = 'hdfs-site'
      update options, (err) ->
        err.message.should.eql 'Required Options: source or properties'
        done()

    it 'error no cluster name (nikita)', ->
      options = Object.assign {}, config.options
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      .then (err) ->
        err.message.should.eql 'Required Options: cluster_name'

    it 'error no config name (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = 'ryba_test'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      .then (err) ->
        err.message.should.eql 'Required Options: config_type'

    it 'error no properties (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = 'ryba_test'
      options.config_type = 'hdfs-site'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      , (err) ->
        err.message.should.eql 'Required Options: source or properties'

    it 'post config without tag (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        throw err if err?

    it 'post config without tag no diffs (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.configs.update options
      , (err, status) ->
        status.should.be.false()
      .then (err) ->
        throw err if err?

    it 'post config with tag (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      options.tag = 'versionOne'
      options_diff = Object.assign {}, options, properties: 'dfs.nameservices': 'ryba_cluster'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.configs.update options_diff
      .then (err) ->
        err.message.should.eql "org.apache.ambari.server.controller.spi.SystemException: An internal system exception occurred: Configuration with tag 'versionOne' exists for 'hdfs-site'"

    # it 'get config with tag (nikita)', ->
    #   options = Object.assign {}, config.options
    #   options.cluster_name = options.name = 'ryba_test'
    #   options.version = 'HDP-2.5'
    #   options.config_type = 'hdfs-site'
    #   options.tag = 'version1'
    #   options.properties =
    #     'dfs.nameservices': 'ryba_test'
    #   nikita
    #   .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
    #   .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
    #   .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
    #   .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
    #   .registry.register ['ambari', 'configs', 'read'], "#{__dirname}/../src/configs/get"
    #   .ambari.cluster.delete options
    #   .ambari.cluster.add options
    #   .ambari.cluster.persist options
    #   .ambari.configs.update options
    #   .ambari.configs.read options
    #   , (err, status, props)  ->
    #     props.should.eql 'dfs.nameservices': 'ryba_test'
    #   .then (err) ->
    #     throw err if err?
