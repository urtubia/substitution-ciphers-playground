
String::rotx = (x) ->
  this.replace /[a-zA-Z]/g, (c) ->
    String.fromCharCode (if ((if c <= "Z" then 90 else 122)) >= (c = c.charCodeAt(0) + x) then c else c - 26)

class Cipher
  encriptSingleLetter: (letter) ->
    letter

  encriptText: (text) ->
    text.replace /[a-zA-Z]/g, (c) =>
      @encriptSingleLetter(c)

  setCanvas: (canvas) ->
    @canvas = canvas
    @updateVisualization()

rgb = (r, g, b) ->
  r: r
  g: g
  b: b

class Caesar extends Cipher

  constructor: ->
    @cellColors = []
    @shiftValue = 0
    for i in [0..25]
      @cellColors[i] =
        animStep: 0
        opacity: 0
        r: 0
        g: 0
        b: 0

    @palette = [
      rgb(0, 160, 176)
      rgb(106,74,60)
      rgb(204,51,63)
      rgb(235,104,65)
      rgb(237,201,81)
    ]

    @paletteIndex = 0

    setInterval () =>
      @updateVisualization()
    , 50

  setShiftValue: (val) ->
    @shiftValue = val
    while @shiftValue < 0
      @shiftValue = 26 + @shiftValue
    @shiftValue = @shiftValue % 26

    @updateVisualization()

  encriptSingleLetter: (letter) ->
    letter.rotx(@shiftValue)

  encriptText: (text) ->
    c = text.slice(-1)
    if c.match /[a-zA-Z]/
      if c >= "a" and c <= "z"
        index = c.charCodeAt(0) - "a".charCodeAt(0)
      if c >= "A" and c <= "Z"
        index = c.charCodeAt(0) - "A".charCodeAt(0)

      @cellColors[index].animStep = 25
      @paletteIndex = (@paletteIndex + 1) % @palette.length
      rgbValue = @palette[@paletteIndex]
      @cellColors[index].r = rgbValue.r
      @cellColors[index].g = rgbValue.g
      @cellColors[index].b = rgbValue.b

    super(text)

  updateVisualization: () ->
    ctx = @canvas.getContext('2d')
    ctx.clearRect 0, 0, 1000, 800
    rectWidth = 20
    xOrigin = 30

    for i in [0..25]
      if @cellColors[i].animStep > 0
        opacity = @cellColors[i].animStep / 25
        r = @cellColors[i].r
        g = @cellColors[i].g
        b = @cellColors[i].b
        ctx.fillStyle = "rgba(#{r},#{g},#{b},#{opacity})"
        ctx.fillRect(xOrigin + rectWidth * i ,40,rectWidth,rectWidth)
        ctx.fillRect(xOrigin + rectWidth * i ,90,rectWidth,rectWidth)
        @cellColors[i].animStep = @cellColors[i].animStep - 1
        ctx.fillStyle = "#000000"
      ctx.strokeRect(xOrigin + rectWidth * i ,40,rectWidth,rectWidth)
      ctx.textAlign = 'center'
      ctx.font = "18px Arial"
      ctx.fillText String.fromCharCode(i + 65), xOrigin + rectWidth * i + (rectWidth / 2), 40 + 17
      ctx.strokeRect(xOrigin + rectWidth * i ,90,rectWidth,rectWidth)
      ctx.fillText String.fromCharCode((i + @shiftValue) % 26 + 65), xOrigin + rectWidth * i + (rectWidth / 2), 90 + 17


currentCipher = null
canvas = null

$ ->
  canvas = $('#visualization')[0]
  canvas.setAttribute 'width', '600'
  canvas.setAttribute 'height', '160'
  currentCipher = new Caesar()
  currentCipher.setCanvas canvas
  $('#plaintext').on 'input', () ->
    encriptedText = currentCipher.encriptText $('#plaintext').text()
    $('#ciphertext').text(encriptedText)


  shiftValueUpdateTimeout = null

  updateShiftValue = () ->
    shiftValue = $('#shiftvalue').text()
    shiftValueInt = parseInt(shiftValue, 10)
    if isNaN(shiftValueInt)
      $('#shiftvalue').text('0')
      shiftValueInt = 0
    currentCipher.setShiftValue shiftValueInt
    encriptedText = currentCipher.encriptText $('#plaintext').text()
    $('#ciphertext').text(encriptedText)
    shiftValueUpdateTimeout = null

  $('#shiftvalue').on 'input', () ->
    if shiftValueUpdateTimeout?
      clearTimeout(shiftValueUpdateTimeout)
    shiftValueUpdateTimeout = setTimeout () ->
      updateShiftValue()
    ,1000






