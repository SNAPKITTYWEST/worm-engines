% Copyright © 2026 Sovereign Source Foundation. All rights reserved.
% Licensed under Sovereign Source License. Commercial use only.
% See LICENSE for complete terms.

-module(worm_mesh_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    worm_mesh_sup:start_link().

stop(_State) ->
    ok.
