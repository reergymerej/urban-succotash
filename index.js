(() => {
  // Mount our Elm app.
  const app = Elm.Main.init({
    node: document.getElementById('elm-app'),
  })

  let count = 0
  document.getElementById('a').addEventListener('click', () => {
    app.ports.portIntoElm.send('This is not an int. :(')
  })

  app.ports.portOutOfElm.subscribe(x => {
    console.log(x)
    document.getElementById('from-elm').innerText = x
  })
})()
