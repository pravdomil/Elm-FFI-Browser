module Clipboard exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


writeText : String -> Task.Task JavaScript.Error ()
writeText a =
    JavaScript.run "navigator.clipboard.writeText(a)"
        (Json.Encode.string a)
        (Json.Decode.succeed ())
