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
    JavaScript.run "a[2] === null ? (a[0] ? sessionStorage : localStorage).removeItem(a[1]) : (a[0] ? sessionStorage : localStorage).setItem(a[1], a[2])"
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

        toMsg_ : Json.Decode.Value -> msg
        toMsg_ b =
            case Json.Decode.decodeValue decoder b of
                Ok ( c, d ) ->
                    case c == a of
                        True ->
                            toMsg d

                        False ->
                            noOperation

                Err _ ->
                    noOperation
    in
    localStorage toMsg_



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
