port module Main exposing (Model, Msg(..), fromJs, init, main, subscriptions, update, view)

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
    { intValue : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { intValue = 0 }
    , Cmd.none
    )



-- UPDATE
-- decodeValue : Decoder a -> Value -> Result Error a
-- type Result error value
--    = Ok value
--    | Err error


decodeValueFromJS : E.Value -> Int
decodeValueFromJS encoded =
    case D.decodeValue D.int encoded of
        Err error ->
            0

        Ok decoded ->
            decoded


type Msg
    = DataFromJS E.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataFromJS encodedValue ->
            ( { intValue = decodeValueFromJS encodedValue
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div []
            [ Html.text (String.fromInt model.intValue)
            ]
        , Html.text "hello"
        ]



-- outgoing


port cache : E.Value -> Cmd msg



-- incoming


port fromJs : (E.Value -> msg) -> Sub msg



-- Don't get confused by the annotation for `fromJs`.
-- Just remember, this is the annotation for subscriptions.


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJs DataFromJS



-- Elm has two kinds of managed effects: commands and subscriptions.
-- Every Cmd specifies
-- (1) which effects you need access to and
-- (2) the type of messages that will come back into your application.
-- You tell Elm to execute a Cmd by returning it from the `update` function.
-- Every Sub specifies
-- (1) which effects you need access to and
-- (2) the type of messages that will come back into your application.
-- I'm not sure of all scenarios, but Subs seem to be executed by the runtime as
-- well.
