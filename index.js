(() => {
  // Mount our Elm app.
  const app = Elm.Main.init({
    node: document.getElementById('elm-app'),
  })

  document.getElementById('a').addEventListener('click', () => {
    app.ports.fromJs.send(Date.now())
  })
})()
