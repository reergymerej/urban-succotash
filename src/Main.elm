port module Main exposing (Model, Msg(..), decodeValueFromJS, fromJs, init, main, subscriptions, update, view)

-- I am needed to send data to JS.

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



-- MODEL


type alias Model =
    { anInt : Int
    , counter : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { anInt = 0
      , counter = 0
      }
    , Cmd.none
    )



-- UPDATE


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
                | anInt = decodeValueFromJS encodedValue
              }
            , Cmd.none
            )

        SendToJSClick ->
            ( model
            , toJs (E.int 42)
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [] [ Html.text ("anInt: " ++ String.fromInt model.anInt) ]
        , Html.button [ Html.Events.onClick SendToJSClick ] [ Html.text "Send Int to JS" ]
        ]



-- incoming


port fromJs : (E.Value -> msg) -> Sub msg



-- outgoing


port toJs : E.Value -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJs DataFromJS
