module WakeLock exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


type WakeLock
    = WakeLock Json.Decode.Value


acquire : Task.Task Error WakeLock
acquire =
    JavaScript.run "navigator.wakeLock.request()"
        Json.Encode.null
        (Json.Decode.value |> Json.Decode.map WakeLock)
        |> Task.mapError toError


release : WakeLock -> Task.Task Error ()
release (WakeLock a) =
    JavaScript.run "a.release()"
        a
        (Json.Decode.succeed ())
        |> Task.mapError toError



--


type Error
    = JavaScriptError JavaScript.Error


toError : JavaScript.Error -> Error
toError a =
    JavaScriptError a
