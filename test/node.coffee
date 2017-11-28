
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  node_add = require '../src/cluster/node_add'
  nikita = require('nikita')()

  describe 'host', ->

    it 'error if no name', (done) ->
      options = Object.assign {}, config.options
      node_add options, (err) ->
        err.message.should.eql 'Required Options: hostname'
        done()

    it 'post host to cluster (nikita)', ->
      #note: node is registered an external cluster (will not delete it)
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.hostname = 'master01.metal.ryba'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'cluster','node_add'], "#{__dirname}/../src/cluster/node_add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.node_add options
      , (err, status) ->
        throw err if err
        status.should.be.true()

    it 'post existing host to cluster (nikita)', ->
      #note: node is registered an external cluster (will not delete it)
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.hostname = 'master01.metal.ryba'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'cluster','node_add'], "#{__dirname}/../src/cluster/node_add"
      .registry.register ['ambari', 'host','add'], "#{__dirname}/../src/hosts/add"
      .registry.register ['ambari', 'host','delete'], "#{__dirname}/../src/hosts/delete"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.node_add options
      .ambari.cluster.node_add options
      , (err, status) ->
        throw err if err
        status.should.be.false()
