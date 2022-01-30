module Console exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


{-| <https://developer.mozilla.org/en-US/docs/Web/API/console>
-}
log : String -> Task.Task JavaScript.Error String
log a =
    JavaScript.run "console.log(a)"
        (Json.Encode.string a)
        (Json.Decode.succeed a)
