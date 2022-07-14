port module Window exposing (init, onFocus)

import JavaScript
import Json.Decode
import Json.Encode
import Task


init : Task.Task JavaScript.Error ()
init =
    JavaScript.run "window.addEventListener('focus', function(e) { scope.ports.window.send(e) })"
        Json.Encode.null
        (Json.Decode.succeed ())


onFocus : msg -> Sub msg
onFocus fn =
    window (\_ -> fn)


port window : (Json.Decode.Value -> msg) -> Sub msg
