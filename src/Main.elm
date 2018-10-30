import Browser
import Html

main =
  Browser.sandbox { init = init, update = update, view = view }

-- MODEL

type alias Model = Int

init : Model
init = 999

-- UPDATE

type Msg = Reset

update : Msg -> Model -> Model
update msg model =
  case msg of
    Reset -> model


-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div [] [Html.text "hello"]
