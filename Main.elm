port module Main exposing (Model, Msg(..), decodeValueFromJS, fromJs, init, main, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Json.Decode as D
import Json.Encode as E


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


type alias Model =
    { valueFromJs : Int
    , counter : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { valueFromJs = 0
      , counter = 0
      }
    , Cmd.none
    )


type Msg
    = DataFromJS E.Value
    | SendToJSClick


decodeValueFromJS : E.Value -> Int
decodeValueFromJS encodedValue =
    -- This is certainly a stupid way to handle this.
    case D.decodeValue D.int encodedValue of
        Err err ->
            -1

        Ok decoded ->
            decoded


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataFromJS encodedValue ->
            ( { model
                | valueFromJs = decodeValueFromJS encodedValue
              }
            , Cmd.none
            )

        SendToJSClick ->
            ( { model
                | counter = model.counter + 1
              }
            , toJs (E.int (model.counter + 1))
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick SendToJSClick ] [ Html.text "Send an Int to JS" ]
        , Html.div [] [ Html.text ("from JS: " ++ String.fromInt model.valueFromJs) ]
        ]



-- incoming


port fromJs : (E.Value -> msg) -> Sub msg



-- outgoing


port toJs : E.Value -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJs DataFromJS
