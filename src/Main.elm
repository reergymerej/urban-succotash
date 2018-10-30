port module Main exposing (..)

import Browser
import Html

-- I am needed to send data to JS.
import Json.Encode as E

main =
  Browser.element { init = init
  , subscriptions = subscriptions
  , update = update
  , view = view
  }

-- MODEL

type alias Model = Int

init : () -> (Model, Cmd Msg)
init _ = (999, Cmd.none)

-- UPDATE

type Msg = Whatevs
  | DataFromJS E.Value

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Whatevs -> (model, Cmd.none)

    DataFromJS encodedValue -> (model, Cmd.none)


-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div [] [Html.text "hello"]







-- outgoing
-- port cache : E.Value -> Cmd msg

-- incoming
port fromJs : (E.Value -> msg) -> Sub msg




subscriptions : Model -> Sub msg
subscriptions model = fromJs
