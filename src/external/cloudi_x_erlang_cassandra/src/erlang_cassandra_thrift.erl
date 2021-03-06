%%
%% Autogenerated by Thrift Compiler (0.9.0)
%%
%% DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
%%

-module(erlang_cassandra_thrift).
%-behaviour(thrift_service).


-include("erlang_cassandra_thrift.hrl").

-export([struct_info/1, function_info/2]).

struct_info('i am a dummy struct') -> undefined.
%%% interface
% login(This, Auth_request)
function_info('login', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'authenticationRequest'}}}]}
;
function_info('login', reply_type) ->
  {struct, []};
function_info('login', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'authenticationException'}}},
          {2, {struct, {'erlang_cassandra_types', 'authorizationException'}}}]}
;
% set_keyspace(This, Keyspace)
function_info('set_keyspace', params_type) ->
  {struct, [{1, string}]}
;
function_info('set_keyspace', reply_type) ->
  {struct, []};
function_info('set_keyspace', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% get(This, Key, Column_path, Consistency_level)
function_info('get', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnPath'}}},
          {3, i32}]}
;
function_info('get', reply_type) ->
  {struct, {'erlang_cassandra_types', 'columnOrSuperColumn'}};
function_info('get', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'notFoundException'}}},
          {3, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {4, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% get_slice(This, Key, Column_parent, Predicate, Consistency_level)
function_info('get_slice', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {4, i32}]}
;
function_info('get_slice', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'columnOrSuperColumn'}}};
function_info('get_slice', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% get_count(This, Key, Column_parent, Predicate, Consistency_level)
function_info('get_count', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {4, i32}]}
;
function_info('get_count', reply_type) ->
  i32;
function_info('get_count', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% multiget_slice(This, Keys, Column_parent, Predicate, Consistency_level)
function_info('multiget_slice', params_type) ->
  {struct, [{1, {list, string}},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {4, i32}]}
;
function_info('multiget_slice', reply_type) ->
  {map, string, {list, {struct, {'erlang_cassandra_types', 'columnOrSuperColumn'}}}};
function_info('multiget_slice', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% multiget_count(This, Keys, Column_parent, Predicate, Consistency_level)
function_info('multiget_count', params_type) ->
  {struct, [{1, {list, string}},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {4, i32}]}
;
function_info('multiget_count', reply_type) ->
  {map, string, i32};
function_info('multiget_count', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% get_range_slices(This, Column_parent, Predicate, Range, Consistency_level)
function_info('get_range_slices', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {2, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {3, {struct, {'erlang_cassandra_types', 'keyRange'}}},
          {4, i32}]}
;
function_info('get_range_slices', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'keySlice'}}};
function_info('get_range_slices', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% get_paged_slice(This, Column_family, Range, Start_column, Consistency_level)
function_info('get_paged_slice', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'keyRange'}}},
          {3, string},
          {4, i32}]}
;
function_info('get_paged_slice', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'keySlice'}}};
function_info('get_paged_slice', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% get_indexed_slices(This, Column_parent, Index_clause, Column_predicate, Consistency_level)
function_info('get_indexed_slices', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {2, {struct, {'erlang_cassandra_types', 'indexClause'}}},
          {3, {struct, {'erlang_cassandra_types', 'slicePredicate'}}},
          {4, i32}]}
;
function_info('get_indexed_slices', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'keySlice'}}};
function_info('get_indexed_slices', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% insert(This, Key, Column_parent, Column, Consistency_level)
function_info('insert', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'column'}}},
          {4, i32}]}
;
function_info('insert', reply_type) ->
  {struct, []};
function_info('insert', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% add(This, Key, Column_parent, Column, Consistency_level)
function_info('add', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnParent'}}},
          {3, {struct, {'erlang_cassandra_types', 'counterColumn'}}},
          {4, i32}]}
;
function_info('add', reply_type) ->
  {struct, []};
function_info('add', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% remove(This, Key, Column_path, Timestamp, Consistency_level)
function_info('remove', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnPath'}}},
          {3, i64},
          {4, i32}]}
;
function_info('remove', reply_type) ->
  {struct, []};
function_info('remove', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% remove_counter(This, Key, Path, Consistency_level)
function_info('remove_counter', params_type) ->
  {struct, [{1, string},
          {2, {struct, {'erlang_cassandra_types', 'columnPath'}}},
          {3, i32}]}
;
function_info('remove_counter', reply_type) ->
  {struct, []};
function_info('remove_counter', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% batch_mutate(This, Mutation_map, Consistency_level)
function_info('batch_mutate', params_type) ->
  {struct, [{1, {map, string, {map, string, {list, {struct, {'erlang_cassandra_types', 'mutation'}}}}}},
          {2, i32}]}
;
function_info('batch_mutate', reply_type) ->
  {struct, []};
function_info('batch_mutate', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% atomic_batch_mutate(This, Mutation_map, Consistency_level)
function_info('atomic_batch_mutate', params_type) ->
  {struct, [{1, {map, string, {map, string, {list, {struct, {'erlang_cassandra_types', 'mutation'}}}}}},
          {2, i32}]}
;
function_info('atomic_batch_mutate', reply_type) ->
  {struct, []};
function_info('atomic_batch_mutate', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% truncate(This, Cfname)
function_info('truncate', params_type) ->
  {struct, [{1, string}]}
;
function_info('truncate', reply_type) ->
  {struct, []};
function_info('truncate', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}}]}
;
% describe_schema_versions(This)
function_info('describe_schema_versions', params_type) ->
  {struct, []}
;
function_info('describe_schema_versions', reply_type) ->
  {map, string, {list, string}};
function_info('describe_schema_versions', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% describe_keyspaces(This)
function_info('describe_keyspaces', params_type) ->
  {struct, []}
;
function_info('describe_keyspaces', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'ksDef'}}};
function_info('describe_keyspaces', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% describe_cluster_name(This)
function_info('describe_cluster_name', params_type) ->
  {struct, []}
;
function_info('describe_cluster_name', reply_type) ->
  string;
function_info('describe_cluster_name', exceptions) ->
  {struct, []}
;
% describe_version(This)
function_info('describe_version', params_type) ->
  {struct, []}
;
function_info('describe_version', reply_type) ->
  string;
function_info('describe_version', exceptions) ->
  {struct, []}
;
% describe_ring(This, Keyspace)
function_info('describe_ring', params_type) ->
  {struct, [{1, string}]}
;
function_info('describe_ring', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'tokenRange'}}};
function_info('describe_ring', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% describe_token_map(This)
function_info('describe_token_map', params_type) ->
  {struct, []}
;
function_info('describe_token_map', reply_type) ->
  {map, string, string};
function_info('describe_token_map', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% describe_partitioner(This)
function_info('describe_partitioner', params_type) ->
  {struct, []}
;
function_info('describe_partitioner', reply_type) ->
  string;
function_info('describe_partitioner', exceptions) ->
  {struct, []}
;
% describe_snitch(This)
function_info('describe_snitch', params_type) ->
  {struct, []}
;
function_info('describe_snitch', reply_type) ->
  string;
function_info('describe_snitch', exceptions) ->
  {struct, []}
;
% describe_keyspace(This, Keyspace)
function_info('describe_keyspace', params_type) ->
  {struct, [{1, string}]}
;
function_info('describe_keyspace', reply_type) ->
  {struct, {'erlang_cassandra_types', 'ksDef'}};
function_info('describe_keyspace', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'notFoundException'}}},
          {2, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% describe_splits(This, CfName, Start_token, End_token, Keys_per_split)
function_info('describe_splits', params_type) ->
  {struct, [{1, string},
          {2, string},
          {3, string},
          {4, i32}]}
;
function_info('describe_splits', reply_type) ->
  {list, string};
function_info('describe_splits', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% trace_next_query(This)
function_info('trace_next_query', params_type) ->
  {struct, []}
;
function_info('trace_next_query', reply_type) ->
  string;
function_info('trace_next_query', exceptions) ->
  {struct, []}
;
% describe_splits_ex(This, CfName, Start_token, End_token, Keys_per_split)
function_info('describe_splits_ex', params_type) ->
  {struct, [{1, string},
          {2, string},
          {3, string},
          {4, i32}]}
;
function_info('describe_splits_ex', reply_type) ->
  {list, {struct, {'erlang_cassandra_types', 'cfSplit'}}};
function_info('describe_splits_ex', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% system_add_column_family(This, Cf_def)
function_info('system_add_column_family', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'cfDef'}}}]}
;
function_info('system_add_column_family', reply_type) ->
  string;
function_info('system_add_column_family', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% system_drop_column_family(This, Column_family)
function_info('system_drop_column_family', params_type) ->
  {struct, [{1, string}]}
;
function_info('system_drop_column_family', reply_type) ->
  string;
function_info('system_drop_column_family', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% system_add_keyspace(This, Ks_def)
function_info('system_add_keyspace', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'ksDef'}}}]}
;
function_info('system_add_keyspace', reply_type) ->
  string;
function_info('system_add_keyspace', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% system_drop_keyspace(This, Keyspace)
function_info('system_drop_keyspace', params_type) ->
  {struct, [{1, string}]}
;
function_info('system_drop_keyspace', reply_type) ->
  string;
function_info('system_drop_keyspace', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% system_update_keyspace(This, Ks_def)
function_info('system_update_keyspace', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'ksDef'}}}]}
;
function_info('system_update_keyspace', reply_type) ->
  string;
function_info('system_update_keyspace', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% system_update_column_family(This, Cf_def)
function_info('system_update_column_family', params_type) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'cfDef'}}}]}
;
function_info('system_update_column_family', reply_type) ->
  string;
function_info('system_update_column_family', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% execute_cql_query(This, Query, Compression)
function_info('execute_cql_query', params_type) ->
  {struct, [{1, string},
          {2, i32}]}
;
function_info('execute_cql_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlResult'}};
function_info('execute_cql_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}},
          {4, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% execute_cql3_query(This, Query, Compression, Consistency)
function_info('execute_cql3_query', params_type) ->
  {struct, [{1, string},
          {2, i32},
          {3, i32}]}
;
function_info('execute_cql3_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlResult'}};
function_info('execute_cql3_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}},
          {4, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% prepare_cql_query(This, Query, Compression)
function_info('prepare_cql_query', params_type) ->
  {struct, [{1, string},
          {2, i32}]}
;
function_info('prepare_cql_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlPreparedResult'}};
function_info('prepare_cql_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% prepare_cql3_query(This, Query, Compression)
function_info('prepare_cql3_query', params_type) ->
  {struct, [{1, string},
          {2, i32}]}
;
function_info('prepare_cql3_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlPreparedResult'}};
function_info('prepare_cql3_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
% execute_prepared_cql_query(This, ItemId, Values)
function_info('execute_prepared_cql_query', params_type) ->
  {struct, [{1, i32},
          {2, {list, string}}]}
;
function_info('execute_prepared_cql_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlResult'}};
function_info('execute_prepared_cql_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}},
          {4, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% execute_prepared_cql3_query(This, ItemId, Values, Consistency)
function_info('execute_prepared_cql3_query', params_type) ->
  {struct, [{1, i32},
          {2, {list, string}},
          {3, i32}]}
;
function_info('execute_prepared_cql3_query', reply_type) ->
  {struct, {'erlang_cassandra_types', 'cqlResult'}};
function_info('execute_prepared_cql3_query', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}},
          {2, {struct, {'erlang_cassandra_types', 'unavailableException'}}},
          {3, {struct, {'erlang_cassandra_types', 'timedOutException'}}},
          {4, {struct, {'erlang_cassandra_types', 'schemaDisagreementException'}}}]}
;
% set_cql_version(This, Version)
function_info('set_cql_version', params_type) ->
  {struct, [{1, string}]}
;
function_info('set_cql_version', reply_type) ->
  {struct, []};
function_info('set_cql_version', exceptions) ->
  {struct, [{1, {struct, {'erlang_cassandra_types', 'invalidRequestException'}}}]}
;
function_info(_Func, _Info) -> no_function.

