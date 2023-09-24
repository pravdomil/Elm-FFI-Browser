module Browser.Extra exposing (..)

import Browser.Navigation
import JavaScript
import Json.Decode
import Json.Encode
import Task


openInNewWindow : String -> Task.Task JavaScript.Error ()
openInNewWindow a =
    JavaScript.run "window.open(a, '_blank')"
        (Json.Encode.string a)
        (Json.Decode.succeed ())


pushUrl : Browser.Navigation.Key -> String -> Task.Task JavaScript.Error ()
pushUrl _ a =
    JavaScript.run "history.pushState({}, '', a)"
        (Json.Encode.string a)
        (Json.Decode.succeed ())


replaceUrl : Browser.Navigation.Key -> String -> Task.Task JavaScript.Error ()
replaceUrl _ a =
    JavaScript.run "history.replaceState({}, '', a)"
        (Json.Encode.string a)
        (Json.Decode.succeed ())
