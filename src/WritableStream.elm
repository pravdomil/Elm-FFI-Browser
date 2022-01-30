module WritableStream exposing (..)

import JavaScript
import Json.Decode
import Task
import WritableStream.Writer


{-| <https://developer.mozilla.org/en-US/docs/Web/API/WritableStream>
-}
type WritableStream
    = WritableStream Json.Decode.Value


writer : WritableStream -> Task.Task Error WritableStream.Writer.Writer
writer (WritableStream a) =
    JavaScript.run "a.getWriter()"
        a
        (Json.Decode.value |> Json.Decode.map WritableStream.Writer.Writer)
        |> Task.mapError
            (\v ->
                case v of
                    JavaScript.Exception "TypeError" _ _ ->
                        Busy

                    _ ->
                        JavaScriptError v
            )



--


type Error
    = Busy
    | JavaScriptError JavaScript.Error
