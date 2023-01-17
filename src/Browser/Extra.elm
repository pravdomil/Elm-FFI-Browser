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


{-| Gets patched by elm-ffi.
-}
safePushUrl : Browser.Navigation.Key -> String -> Cmd msg
safePushUrl =
    Browser.Navigation.pushUrl


{-| Gets patched by elm-ffi.
-}
safeReplaceUrl : Browser.Navigation.Key -> String -> Cmd msg
safeReplaceUrl =
    Browser.Navigation.replaceUrl
