import Html


-- MODEL

type alias Model = Int


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
