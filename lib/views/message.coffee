# This file is imported in views/panel

class Message extends HTMLElement
  initialize: (@message, @addPath)->

  attachedCallback: ->
    @appendChild Message.renderRibbon(@message.type)
    @appendChild Message.renderMessage(@message)
    @appendChild Message.renderLink(@message, @addPath) if @message.file

  @renderLink: (message, addPath)->
    displayFile = message.file
    try
      atom.project.getPaths().forEach (path) =>
        return if message.file.indexOf(path) isnt 0 or displayFile isnt message.file # Avoid double replacing
        displayFile = message.file.substr( path.length + 1 ) # Remove the trailing slash as well
        throw null
    El = document.createElement 'a'
    El.addEventListener 'click', ->
      Message.onClick message.file, message.position
    if message.position
      El.textContent = "at line #{message.position[0][0]} col #{message.position[0][1]} "
    if addPath
      El.textContent += "in #{displayFile}"
    El

  @renderRibbon: (type)->
    El = document.createElement 'span'
    El.classList.add 'badge'
    El.classList.add 'badge-flexible'
    El.classList.add "badge-#{type.toLowerCase()}"
    El.textContent = type
    El

  @renderMessage: (message)->
    El = document.createElement 'span'
    if message.html
      El.innerHTML = message.html
    else
      El.textContent = message.message
    El

  @onClick: (file, position)->
    atom.workspace.open(file).then ->
      return unless position
      atom.workspace.getActiveTextEditor().setCursorBufferPosition(
        [position[0][0] - 1, position[0][1] - 1]
      )

module.exports = document.registerElement('linter-message', {prototype: Message.prototype})