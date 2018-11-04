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

    -- Maybe String because it may _not_ be there.  Instead of trying to convert
    -- the value to a String, and maybe an empty "" when there's an error (that
    -- is confusing, right?), just store a Maybe String.  Deal with its presence
    -- or absence when we want to use it for something (like rendering the
    -- view).
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

      -- When it's not there, just use Nothing.
      , decodeError = Maybe.Nothing
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
When that Sub is activated, it results in `GotValueFromJs Json.Encode.Value` being generated.
--}


subscriptions : Model -> Sub Msg
subscriptions model =
    portIntoElm GotValueFromJs



--------------------------------------------------------------------------------
-- update - a function called when an action happens, updates the model and issues a command
{--
Here we define a port we use to send values _out_ of Elm.  As in other areas,
we can't tell the runtime when to do the stuff, we just issue a command.  So
the ported function will be called with a Json.Encode.Value and return a
command.
--}


port portOutOfElm : Json.Encode.Value -> Cmd msg



{--
When an action happens, `update` is called with a message and the current model.
This is where we can return a new model and a command.
--}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- If the message ws SendDataToJs
        SendDataToJs ->
            -- Return a model with a modified `valueForJs` value
            ( { model
                | valueForJs = model.valueForJs + 1
              }
              -- and a command (Cmd Msg, courtesy of portOutOfElm) telling the
              -- runtime to call the ported function.
            , portOutOfElm (Json.Encode.int (model.valueForJs + 1))
            )

        -- We get this from our subscription to portIntoElm.
        GotValueFromJs encodedValue ->
            -- In `update`, we always need to return `(Model, Cmd Msg)`.
            -- Decoding JSON can fail, so we need to account for that.
            -- Here, we _try_ to decode `encodedValue`, which gives us a Result.
            case Json.Decode.decodeValue Json.Decode.int encodedValue of
                -- If it was an error
                Err err ->
                    -- return the model
                    ( { model
                        -- updated with the error converted to a string.
                        -- `decodeError` is a `Maybe String`, so we assign it
                        -- with `Maybe.Just`.
                        | decodeError = Maybe.Just (Json.Decode.errorToString err)
                      }
                      -- no commands needed
                    , Cmd.none
                    )

                -- If the decode was Ok
                Ok decoded ->
                    -- return the model
                    ( { model
                        -- with the updated value.
                        | valueFromJs = decoded
                      }
                      -- no commands needed
                    , Cmd.none
                    )



--------------------------------------------------------------------------------
-- view - a function called when the model is updated, returns html to render
{--
This deals with our Maybe String.
If it is Nothing, return nothing.
If it is Just something, return it as a text node.
This is basic rendering stuff, but the use of `case` to handle `Maybe` values
may not be obvious.
--}


decodeErrorView : Maybe String -> Html.Html Msg
decodeErrorView maybeDecodeError =
    case maybeDecodeError of
        Maybe.Nothing ->
            Html.div [] []

        Maybe.Just decodeErrorString ->
            Html.div [] [ Html.text decodeErrorString ]



-- This is called when the model has been updated and we need to generate new
-- Html for the app.  It returns Html.Html Msg, which is basically some html
-- that can potentially cause a a Msg to be emitted.


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
