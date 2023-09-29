port module Storage exposing
    ( Storage(..), get, set
    , init, onChange
    )

{-|

@docs Storage, get, set
@docs init, onChange

-}

import JavaScript
import Json.Decode
import Json.Encode
import Task


{-| <https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage>
<https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage>
-}
type Storage
    = Local String
    | Session String


get : Storage -> Task.Task JavaScript.Error (Maybe String)
get a =
    JavaScript.run "(a[0] ? sessionStorage : localStorage).getItem(a[1])"
        (encode Nothing a)
        (Json.Decode.nullable Json.Decode.string)


set : Maybe String -> Storage -> Task.Task JavaScript.Error ()
set value a =
    JavaScript.run "a.c === null ? (a.a ? sessionStorage : localStorage).removeItem(a.b) : (a.a ? sessionStorage : localStorage).setItem(a.b, a.c)"
        (encode value a)
        (Json.Decode.succeed ())


init : Task.Task JavaScript.Error ()
init =
    JavaScript.run "addEventListener('storage', function(e) { scope.ports.localStorage.send([e.storageArea === sessionStorage, e]) })"
        Json.Encode.null
        (Json.Decode.succeed ())


onChange : msg -> (Maybe String -> msg) -> Storage -> Sub msg
onChange noOperation toMsg a =
    let
        decoder : Json.Decode.Decoder ( Storage, Maybe String )
        decoder =
            Json.Decode.map2 Tuple.pair
                (Json.Decode.field "a" Json.Decode.bool
                    |> Json.Decode.andThen
                        (\x ->
                            Json.Decode.at [ "b", "key" ] Json.Decode.string
                                |> Json.Decode.map
                                    (if x then
                                        Session

                                     else
                                        Local
                                    )
                        )
                )
                (Json.Decode.at [ "b", "newValue" ] (Json.Decode.nullable Json.Decode.string))
    in
    localStorage
        (\x ->
            x
                |> Json.Decode.decodeValue decoder
                |> Result.toMaybe
                |> Maybe.andThen
                    (\( x2, x3 ) ->
                        if x2 == a then
                            Just (toMsg x3)

                        else
                            Nothing
                    )
                |> Maybe.withDefault noOperation
        )



--


port localStorage : (Json.Decode.Value -> msg) -> Sub msg


encode : Maybe String -> Storage -> Json.Encode.Value
encode value a =
    case a of
        Local b ->
            Json.Encode.list identity
                [ Json.Encode.int 0
                , Json.Encode.string b
                , case value of
                    Just c ->
                        Json.Encode.string c

                    Nothing ->
                        Json.Encode.null
                ]

        Session b ->
            Json.Encode.list identity
                [ Json.Encode.int 1
                , Json.Encode.string b
                , case value of
                    Just c ->
                        Json.Encode.string c

                    Nothing ->
                        Json.Encode.null
                ]
