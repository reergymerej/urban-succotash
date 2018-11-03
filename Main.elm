port module Main exposing (Model, Msg(..), init, main, portIntoElm, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Json.Decode
import Json.Encode



{--
This module is making the `main` app.  It's created at the very end of the file.
You may want to peek at that first so this makes sense.  Basically, we're
making:
  * init
  * subscriptions
  * update
  * view
--}
--------------------------------------------------------------------------------
-- init - a function that initializes the model and initial command
{--
As before, I feel uncomfortable refering to things before they're defined,
although they get "hoisted" and it's syntactically correct.  I prefer to define
the elements I need, _then_ use them.  This section defines the `init` function
at the end.
--}
{--
We will need to define the _shape_ of our Model.  Technically, we don't have to,
but realistically, we do.  This is just an alias, so we can refer to this
structure throughout the code.
--}


type alias Model =
    { valueFromJs : Int
    , decodeError : Maybe String
    , valueForJs : Int
    }



{--
Messages are sent around the app when an action occurs.  Here we define the
different types of messages in our app.
--}


type Msg
    = GotValueFromJs Json.Encode.Value
    | SendDataToJs



{--
Now we set our initial model and command.  Commands tell the runtime to go do
something for us.  We're not sending a command yet, but we still needed to have
our Msg defined as it's part of the signature.  (This returns the same as
`update`.)
--}


init : () -> ( Model, Cmd Msg )
init _ =
    ( { valueFromJs = 0
      , decodeError = Nothing
      , valueForJs = 0
      }
    , Cmd.none
    )



--------------------------------------------------------------------------------
-- subscriptions - side effects from the runtime we watch for
{--
We're subscribing to a function we've ported.  The annotation is a little
confusing.  It basically takes a function that returns a msg, then passes that
msg to a Sub.  It returns a `Sub msg`.  That's a `Sub` that will work with any
kind of Msg.  We defined our Msg above.
--}


port portIntoElm : (Json.Encode.Value -> msg) -> Sub msg



{--
When `portIntoElm` is called, send the `GotValueFromJs` message, including the
Json.Encode.Value.

In other words, we have a Msg type that is `GotValueFromJs Json.Encode.Value`.
Incoming ported functions get a Json.Encode.Value that they tack onto a Sub.
When that Sub is activated, it results in
`GotValueFromJs Json.Encode.Value` being generated.
--}


subscriptions : Model -> Sub Msg
subscriptions model =
    portIntoElm GotValueFromJs



--------------------------------------------------------------------------------
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



--------------------------------------------------------------------------------
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



--------------------------------------------------------------------------------
{--
The main application can't use sandbox.  We use Browser.element instead.  It
takes:
* init - a function that initializes the model and initial command
* subscriptions - side effects from the runtime we watch for
* update - a function called when an action happens, updates the model and issues a command
* view - a function called when the model is updated, returns html to render

This is usually set at the top in the code I've seen, but it's weird for me to
refer to all these things _before_ I've seen them.
--}


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
