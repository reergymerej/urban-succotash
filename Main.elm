port module Main exposing (Model, Msg(..), fromJs, init, main, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Json.Decode
import Json.Encode


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { valueFromJs = 0
      , valueForJs = 0
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJs DataFromJS


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendToJSClick ->
            let
                newValue =
                    model.valueForJs + 1
            in
            ( { model
                | valueForJs = newValue
              }
            , toJs (Json.Encode.int newValue)
            )

        DataFromJS encodedValue ->
            case Json.Decode.decodeValue Json.Decode.int encodedValue of
                Err err ->
                    ( model, Cmd.none )

                Ok decoded ->
                    ( { model
                        | valueFromJs = decoded
                      }
                    , Cmd.none
                    )


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick SendToJSClick ] [ Html.text "Send an Int to JS" ]
        , Html.div [] [ Html.text ("from JS: " ++ String.fromInt model.valueFromJs) ]
        ]


type alias Model =
    { valueFromJs : Int
    , valueForJs : Int
    }


type Msg
    = DataFromJS Json.Encode.Value
    | SendToJSClick


port fromJs : (Json.Encode.Value -> msg) -> Sub msg


port toJs : Json.Encode.Value -> Cmd msg
