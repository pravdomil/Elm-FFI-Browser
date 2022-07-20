module Browser.Extra exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


openInNewWindow : String -> Task.Task JavaScript.Error ()
openInNewWindow a =
    JavaScript.run "window.open(a, '_blank')"
        (Json.Encode.string a)
        (Json.Decode.succeed ())
