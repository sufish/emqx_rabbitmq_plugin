%%%-------------------------------------------------------------------
%%% @author sufis
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 9月 2024 16:24
%%%-------------------------------------------------------------------
-module(emqx_rabbitmq_plugin_conn).
-author("sufis").
-behavior(ecpool_worker).
-include_lib("amqp_client/include/amqp_client.hrl").

%% API
-export([connect/1, ensure_exchange/1, publish/3]).

connect(Opts) ->
  URI = proplists:get_value(uri, Opts),
  {ok, ConnOpts} = amqp_uri:parse(URI),
  amqp_connection:start(ConnOpts).

ensure_exchange(ExchangeName) ->
  ecpool:with_client(emqx_rabbitmq_plugin, fun(C) -> ensure_exchange(ExchangeName, C) end).

ensure_exchange(ExchangeName, Conn) ->
  {ok, Channel} = amqp_connection:open_channel(Conn),
  Declare = #'exchange.declare'{exchange = ExchangeName, durable = true},
  #'exchange.declare_ok'{} = amqp_channel:call(Channel, Declare),
  amqp_channel:close(Channel).

publish(ExchangeName, Payload, RoutingKey) ->
  ecpool:with_client(emqx_rabbitmq_plugin, fun(C) -> publish(ExchangeName, Payload, RoutingKey, C) end).

publish(ExchangeName, Payload, RoutingKey, Conn) ->
  {ok, Channel} = amqp_connection:open_channel(Conn),
  Publish = #'basic.publish'{exchange = ExchangeName, routing_key = RoutingKey},
  Props = #'P_basic'{delivery_mode = 2},
  Msg = #amqp_msg{props = Props, payload = Payload},
  amqp_channel:cast(Channel, Publish, Msg),
  amqp_channel:close(Channel).
