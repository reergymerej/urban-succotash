port module Main exposing (Model, Msg(..), init, main, portIntoElm, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Json.Decode
import Json.Encode



-- init


type alias Model =
    { valueFromJs : Int
    , decodeError : Maybe String
    , valueForJs : Int
    }


type Msg
    = GotValueFromJs Json.Encode.Value
    | SendDataToJs


init : () -> ( Model, Cmd Msg )
init _ =
    ( { valueFromJs = 0
      , decodeError = Nothing
      , valueForJs = 0
      }
    , Cmd.none
    )



-- subscriptions


port portIntoElm : (Json.Encode.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    portIntoElm GotValueFromJs



-- update


port portOutOfElm : Json.Encode.Value -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendDataToJs ->
            ( { model
                | valueForJs = model.valueForJs + 1
              }
            , portOutOfElm (Json.Encode.int (model.valueForJs + 1))
            )

        GotValueFromJs encodedValue ->
            case Json.Decode.decodeValue Json.Decode.int encodedValue of
                Err err ->
                    ( { model
                        | decodeError = Maybe.Just (Json.Decode.errorToString err)
                      }
                    , Cmd.none
                    )

                Ok decoded ->
                    ( { model
                        | valueFromJs = decoded
                      }
                    , Cmd.none
                    )



-- view


decodeErrorView : Maybe String -> Html.Html Msg
decodeErrorView maybeDecodeError =
    case maybeDecodeError of
        Nothing ->
            Html.div [] []

        Just decodeErrorString ->
            Html.div [] [ Html.text decodeErrorString ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick SendDataToJs ] [ Html.text "Send an Int to JS" ]
        , Html.div [] [ Html.text (String.fromInt model.valueFromJs) ]
        , decodeErrorView model.decodeError
        ]


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
