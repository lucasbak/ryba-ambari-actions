
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  persist = require '../src/cluster/persist'
  nikita = require('nikita')()


  describe 'stacks actions', ->

    it 'finalise ambari in progress (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.stack_name = 'HDP'
      options.stack_version = '2.5'
      options.repository_version = '2.5.3.0'
      options.display_name = 'HDP-2.5.3.0'
      options.repositories = [
        os_type:'redhat7'
        repo_id: 'HDP-2.5'
        repo_name: 'HDP'
        base_url: 'http://10.10.10.1:10080/centos7/hdp_2.5.3.0/HDP/centos6/2.x/updates/2.5.3.0'
      ,
        os_type:'redhat7'
        repo_id: 'HDP-UTILS-1.1.0.21'
        repo_name: 'HDP-UTILS'
        base_url: 'http://10.10.10.1:10080/centos7/hdp_2.5.3.0/HDP-UTILS-1.1.0.21/repos/centos6'
      ]
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'stacks','repository_add'], "#{__dirname}/../src/stacks/repository_version_add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.stacks.repository_add options
      , (err, status) ->
        status.should.be.true()
      .next (err) ->
        throw err if err?
