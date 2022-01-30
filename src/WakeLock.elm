module WakeLock exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


{-| <https://developer.mozilla.org/en-US/docs/Web/API/WakeLock>
-}
type WakeLock
    = WakeLock Json.Decode.Value


acquire : Task.Task Error WakeLock
acquire =
    JavaScript.run "navigator.wakeLock.request()"
        Json.Encode.null
        (Json.Decode.value |> Json.Decode.map WakeLock)
        |> Task.mapError
            (\v ->
                case v of
                    _ ->
                        JavaScriptError v
            )


release : WakeLock -> Task.Task Error ()
release (WakeLock a) =
    JavaScript.run "a.release()"
        a
        (Json.Decode.succeed ())
        |> Task.mapError
            (\v ->
                case v of
                    _ ->
                        JavaScriptError v
            )



--


type Error
    = JavaScriptError JavaScript.Error
