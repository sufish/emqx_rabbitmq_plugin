-module(emqx_rabbitmq_plugin_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqx_rabbitmq_plugin_sup:start_link(),
    emqx_rabbitmq_plugin:load(application:get_all_env()),

    emqx_ctl:register_command(emqx_rabbitmq_plugin, {emqx_rabbitmq_plugin_cli, cmd}),
    {ok, Sup}.

stop(_State) ->
    emqx_ctl:unregister_command(emqx_rabbitmq_plugin),
    emqx_rabbitmq_plugin:unload().
