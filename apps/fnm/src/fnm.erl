-module(fnm).

-export([ send_cmd/2
        , get_resp/0
        , device_id/1
        , ha_gain_request/4
        , ha_gain_setting/4
        ]).

send_cmd(Port, Cmd) when is_binary(Cmd) ->
    ChkSum = checksum(Cmd),
    Data = iolist_to_binary([Cmd, ChkSum]),
    Length = binary:referenced_byte_size(Data),
    Port ! {send, iolist_to_binary([Length, Data])}.

checksum(Cmd) ->
    do_checksum(Cmd, 0).

do_checksum(<<H:8, T/binary>>, Sum) ->
    do_checksum(T, Sum+H rem 16#100);
do_checksum(<<>>, Sum) ->
    ChkSum = 16#ff - Sum,
    <<ChkSum>>.

get_resp() ->
    receive
        Data ->
            Data
    after
        100 ->
            timeout
    end.

device_id(Port) ->
    send_cmd(Port, <<0,0>>).

ha_gain_request(Port, Id, Channel, Num) ->
    send_cmd(Port, <<16#60, Id, Channel, Num>>).

ha_gain_setting(Port, Id, StartChannel, GainList)
  when length(GainList) + StartChannel =< 8 ->
    send_cmd(Port, iolist_to_binary([16#20, Id, StartChannel, GainList])).
