-module(erlang_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Erlang app started on node: ~p~n", [node()]),
    erlang_app_sup:start_link().

stop(_State) ->
    ok.
