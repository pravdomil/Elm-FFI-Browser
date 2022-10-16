module WritableStream.Writer exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


{-| <https://developer.mozilla.org/en-US/docs/Web/API/WritableStreamDefaultWriter>
-}
type Writer
    = Writer Json.Decode.Value


write : String -> Writer -> Task.Task Error Writer
write data a =
    JavaScript.run "a.a.write(new TextEncoder().encode(a.b))"
        (Json.Encode.object
            [ ( "a", a |> (\(Writer v) -> v) )
            , ( "b", data |> Json.Encode.string )
            ]
        )
        (Json.Decode.succeed a)
        |> Task.mapError
            (\x ->
                case x of
                    JavaScript.Exception "NetworkError" _ _ ->
                        Disconnected

                    _ ->
                        JavaScriptError x
            )


close : Writer -> Task.Task Error ()
close (Writer a) =
    JavaScript.run "a.close()"
        a
        (Json.Decode.succeed ())
        |> Task.mapError
            (\x ->
                case x of
                    _ ->
                        JavaScriptError x
            )



--


type Error
    = Disconnected
    | JavaScriptError JavaScript.Error
