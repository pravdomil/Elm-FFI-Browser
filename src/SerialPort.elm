module SerialPort exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task
import WritableStream


{-| <https://developer.mozilla.org/en-US/docs/Web/API/SerialPort>
-}
type SerialPort
    = SerialPort Json.Decode.Value


request : Task.Task Error SerialPort
request =
    JavaScript.run
        "navigator.serial.getPorts().then(a => a.length === 0 ? navigator.serial.requestPort() : a[0])"
        Json.Encode.null
        (Json.Decode.value |> Json.Decode.map SerialPort)
        |> Task.mapError toError
        |> Task.mapError
            (\v ->
                case v of
                    JavaScriptError (JavaScript.Exception "NotFoundError" _ _) ->
                        NothingSelected

                    _ ->
                        v
            )


writableStream : Options -> SerialPort -> Task.Task Error WritableStream.WritableStream
writableStream options (SerialPort a) =
    JavaScript.run "a.a.writable ? a.a.writable : a.a.open(a.b).then(_ => a.a.writable)"
        (Json.Encode.object
            [ ( "a", a )
            , ( "b", options |> encodeOptions )
            ]
        )
        (Json.Decode.value |> Json.Decode.map WritableStream.WritableStream)
        |> Task.mapError toError



--


type alias Options =
    { baudRate : Int
    , bufferSize : Maybe Int
    , dataBits : Maybe Int
    , flowControl : Maybe FlowControl
    , parity : Maybe Parity
    , stopBits : Maybe Int
    }


defaultOptions : Options
defaultOptions =
    Options 9600 Nothing Nothing Nothing Nothing Nothing


encodeOptions : Options -> Json.Decode.Value
encodeOptions options =
    [ ( "baudRate"
      , options.baudRate |> Json.Encode.int |> Just
      )
    , ( "bufferSize"
      , options.bufferSize |> Maybe.map Json.Encode.int
      )
    , ( "dataBits"
      , options.dataBits |> Maybe.map Json.Encode.int
      )
    , ( "flowControl"
      , options.flowControl |> Maybe.map (flowControlToString >> Json.Encode.string)
      )
    , ( "parity"
      , options.parity |> Maybe.map (parityToString >> Json.Encode.string)
      )
    , ( "stopBits"
      , options.stopBits |> Maybe.map Json.Encode.int
      )
    ]
        |> List.filterMap (\( k, v ) -> v |> Maybe.map (Tuple.pair k))
        |> Json.Encode.object



--


type FlowControl
    = NoFlowControl
    | Hardware


flowControlToString : FlowControl -> String
flowControlToString a =
    case a of
        NoFlowControl ->
            "none"

        Hardware ->
            "hardware"



--


type Parity
    = NoParity
    | Even
    | Odd


parityToString : Parity -> String
parityToString a =
    case a of
        NoParity ->
            "none"

        Even ->
            "even"

        Odd ->
            "odd"



--


type Error
    = NotSupported
    | NothingSelected
    | JavaScriptError JavaScript.Error


toError : JavaScript.Error -> Error
toError a =
    case a of
        JavaScript.Exception "ReferenceError" _ _ ->
            NotSupported

        _ ->
            JavaScriptError a
