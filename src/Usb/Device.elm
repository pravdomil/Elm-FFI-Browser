module Usb.Device exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


{-| <https://developer.mozilla.org/en-US/docs/Web/API/USBDevice>
-}
type Device
    = Device Json.Decode.Value


request : List Filter -> Task.Task Error Device
request filters =
    JavaScript.run
        "navigator.usb.getDevices().then(b => b.length === 0 ? navigator.usb.requestDevice({ filters: a.a }) : b[0])"
        (Json.Encode.object
            [ ( "a", filters |> Json.Encode.list encodeFilter )
            ]
        )
        (Json.Decode.value |> Json.Decode.map Device)
        |> Task.mapError
            (\x ->
                case x of
                    JavaScript.Exception (JavaScript.ErrorName "ReferenceError") _ _ ->
                        NotSupported

                    JavaScript.Exception (JavaScript.ErrorName "NotFoundError") _ _ ->
                        NothingSelected

                    _ ->
                        JavaScriptError x
            )


open : Device -> Task.Task Error Device
open a =
    JavaScript.run
        "a.open()"
        (a |> (\(Device x) -> x))
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )


selectConfiguration : Int -> Device -> Task.Task Error Device
selectConfiguration value a =
    JavaScript.run
        "a.a.selectConfiguration(a.b)"
        (Json.Encode.object
            [ ( "a", a |> (\(Device x) -> x) )
            , ( "b", value |> Json.Encode.int )
            ]
        )
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )


claimInterface : Int -> Device -> Task.Task Error Device
claimInterface number a =
    JavaScript.run
        "a.a.claimInterface(a.b)"
        (Json.Encode.object
            [ ( "a", a |> (\(Device x) -> x) )
            , ( "b", number |> Json.Encode.int )
            ]
        )
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )


transferOut : Int -> String -> Device -> Task.Task Error Device
transferOut endpoint data a =
    JavaScript.run
        "a.a.transferOut(a.b, new TextEncoder().encode(a.c))"
        (Json.Encode.object
            [ ( "a", a |> (\(Device x) -> x) )
            , ( "b", endpoint |> Json.Encode.int )
            , ( "c", data |> Json.Encode.string )
            ]
        )
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    JavaScript.Exception (JavaScript.ErrorName "AbortError") _ _ ->
                        TransferAborted

                    _ ->
                        JavaScriptError x
            )


close : Device -> Task.Task Error ()
close a =
    JavaScript.run
        "a.close()"
        (a |> (\(Device x) -> x))
        (Json.Decode.succeed ())
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )


reset : Device -> Task.Task Error Device
reset a =
    JavaScript.run
        "a.reset()"
        (a |> (\(Device x) -> x))
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )



--


type alias Filter =
    { vendorId : Maybe Int
    , productId : Maybe Int
    , classCode : Maybe Int
    , subclassCode : Maybe Int
    , protocolCode : Maybe Int
    , serialNumber : Maybe String
    }


encodeFilter : Filter -> Json.Decode.Value
encodeFilter a =
    [ ( "vendorId", a.vendorId |> Maybe.map Json.Encode.int )
    , ( "productId", a.productId |> Maybe.map Json.Encode.int )
    , ( "classCode", a.classCode |> Maybe.map Json.Encode.int )
    , ( "subclassCode", a.subclassCode |> Maybe.map Json.Encode.int )
    , ( "protocolCode", a.protocolCode |> Maybe.map Json.Encode.int )
    , ( "serialNumber", a.serialNumber |> Maybe.map Json.Encode.string )
    ]
        |> List.filterMap (\( x, x2 ) -> x2 |> Maybe.map (Tuple.pair x))
        |> Json.Encode.object



--


type Error
    = NotSupported
    | NothingSelected
    | TransferAborted
    | JavaScriptError JavaScript.Error
