%% WORM Engines Supervisor Tree

-module(worm_sup).
-behavior(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one, intensity => 5, period => 10},

  ChildSpecs = [
    %% Key management ETS table
    #{id => worm_keys_table,
      start => {?MODULE, start_ets, [worm_keys]}},

    %% Replication coordinators (started on demand per node)
    %% Will be dynamically supervised
  ],

  {ok, {SupFlags, ChildSpecs}}.

%% Helper to start ETS tables
start_ets(TableName) ->
  ets:new(TableName, [public, named_table]),
  {ok, self()}.
