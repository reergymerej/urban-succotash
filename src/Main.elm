port module Main exposing (..)

-- I am needed to send data to JS.

import Browser
import Html
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
    Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( 999, Cmd.none )



-- UPDATE


type Msg
    = Whatevs
    | DataFromJS E.Value


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
        Whatevs ->
            ( model, Cmd.none )

        DataFromJS encodedValue ->
            ( decodeValueFromJS encodedValue
            , Cmd.none
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [] [ Html.text ("model: " ++ String.fromInt model) ]
        ]



-- outgoing


port fromJs : (E.Value -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJs DataFromJS
