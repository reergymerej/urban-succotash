import Browser
import Html

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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Whatevs -> (model, Cmd.none)


-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div [] [Html.text "hello"]


subscriptions : Model -> Sub msg
subscriptions model = Sub.none
