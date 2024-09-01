-module(emqx_rabbitmq_plugin_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    application:set_env(amqp_client, prefer_ipv6, false),
    {ok, ConfigMap} =  emqx_plugins:get_config(emqx_plugins:make_name_vsn_string("emqx_rabbitmq_plugin", "1.0.0")),
    PoolOpts = [
        {uri, emqx_utils_maps:deep_get([<<"rabbitmq">>, <<"uri">>], ConfigMap)},
        {pool_size, emqx_utils_maps:deep_get([<<"rabbitmq">>, <<"poolSize">>], ConfigMap)},
        {auto_reconnect, emqx_utils_maps:deep_get([<<"rabbitmq">>, <<"reconnect">>], ConfigMap)}
    ],
    application:set_env(emqx_rabbitmq_plugin, exchange, emqx_utils_maps:deep_get([<<"exchange">>], ConfigMap)),
    PoolSpec = ecpool:pool_spec(emqx_rabbitmq_plugin, emqx_rabbitmq_plugin, emqx_rabbitmq_plugin_conn, PoolOpts),
    {ok, { {one_for_all, 0, 1}, [PoolSpec]} }.
