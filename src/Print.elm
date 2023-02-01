port module Print exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


init : Task.Task JavaScript.Error ()
init =
    JavaScript.run "(function() { window.addEventListener('beforeprint', function(e) { scope.ports.beforeprint.send(e) }); window.addEventListener('afterprint', function(e) { scope.ports.afterprint.send(e) }) })()"
        Json.Encode.null
        (Json.Decode.succeed ())


onPrint : msg -> Sub msg
onPrint fn =
    beforeprint (\_ -> fn)


printDone : msg -> Sub msg
printDone fn =
    afterprint (\_ -> fn)


port beforeprint : (Json.Decode.Value -> msg) -> Sub msg


port afterprint : (Json.Decode.Value -> msg) -> Sub msg
