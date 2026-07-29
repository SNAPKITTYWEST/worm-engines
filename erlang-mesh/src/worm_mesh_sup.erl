% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_sup).
-behaviour(supervisor).

-export([start_link/0, start_node/2]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_node(NumReplicas, NodeId) ->
    supervisor:start_child(?SERVER, 
        [NumReplicas, NodeId]).

init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 5, period => 60},
    ChildSpecs = [
        #{id => worm_mesh_node,
          start => {worm_mesh_node, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => worker,
          modules => [worm_mesh_node]}
    ],
    {ok, {SupFlags, ChildSpecs}}.
