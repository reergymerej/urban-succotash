(() => {
  // Mount our Elm app.
  const app = Elm.Main.init({
    node: document.getElementById('elm-app'),
  })

  let count = 0
  document.getElementById('a').addEventListener('click', () => {
    app.ports.fromJs.send(++count)
  })

  app.ports.toJs.subscribe(x => {
    console.log(x)
    document.getElementById('from-elm').innerText = x
  })
})()
