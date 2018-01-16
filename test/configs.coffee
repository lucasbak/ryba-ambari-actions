
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  group_add = require '../src/configs/groups/add'
  persist = require '../src/cluster/persist'
  update = require '../src/configs/update'
  nikita = require('nikita')()


  describe 'configs actions', ->

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
      options.debug = true
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
      options_diff = Object.assign {}, options, properties: 'dfs.nameservices': 'ryba_cluster', version: null
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

    it 'post config without from source tag (nikita)', ->
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
    it.only 'create config groups without hosts (nikita)', (done) ->
      options = Object.assign {}, config.options
      options.tag = "config_group_test"
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.group_name = 'advanced_zookeeper'
      options.desired_configs =
        type: 'zoo.cfg'
        tag: 'slow_zookeeper'
        properties: 'tickTime': '5000'
      options.hosts = []
      # options.debug = true
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'configs', 'groups', 'add'], "#{__dirname}/../src/configs/groups/add"
      .registry.register ['ambari', 'configs', 'groups', 'delete'], "#{__dirname}/../src/configs/groups/delete"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.groups.delete options
      .ambari.configs.groups.add options
      , (err, status) ->
        status.should.be.true()
      .next (err) ->
        done err
      # .next (err) ->
      #   done err
      # group_add options, (err, status) ->
      #   console.log err, status
      # nikita
      # .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      # .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      # .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      # .registry.register ['ambari', 'configs', 'groups', 'add'], "#{__dirname}/../src/configs/groups/add"
      # .ambari.cluster.delete options
      # .ambari.cluster.add options
      # .ambari.configs.groups.add options
      # .next (err) ->
      #   console.log err
      #   err.should.be.null()
