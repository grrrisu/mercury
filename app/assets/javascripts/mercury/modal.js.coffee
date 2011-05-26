Mercury.modal = (url, options) ->
  Mercury.modal.show(url, options)
  return Mercury.modal

$.extend Mercury.modal, {

  minWidth: 400

  show: (@url, @options = {}) ->
    Mercury.trigger('focus:window')
    @initialize()
    if @visible then @update() else @appear()


  initialize: ->
    return if @initialized
    @build()
    @bindEvents()
    @initialized = true


  build: ->
    @element = $('<div>', {class: 'mercury-modal loading'})
    @element.html('<h1 class="mercury-modal-title"><span></span><a>&times;</a></h1>')
    @element.append('<div class="mercury-modal-content-container"><div class="mercury-modal-content"></div></div>')

    @overlay = $('<div>', {class: 'mercury-modal-overlay'})

    @titleElement = @element.find('.mercury-modal-title')
    @contentContainerElement = @element.find('.mercury-modal-content-container')
    @contentElement = @element.find('.mercury-modal-content')

    @element.appendTo($(@options.appendTo).get(0) ? 'body')
    @overlay.appendTo($(@options.appendTo).get(0) ? 'body')

    @titleElement.find('span').html(@options.title)


  bindEvents: ->
    Mercury.bind 'refresh', => @resize(true)
    Mercury.bind 'resize', => @position()

    @overlay.click => @hide()

    @titleElement.find('a').click => @hide()


  appear: ->
    @position()

    @overlay.show()
    @overlay.animate {opacity: 1}, 200, 'easeInOutSine', =>
      @element.css({top: -@element.height()})
      @setTitle()
      @element.show()
      @element.animate {top: 0}, 200, 'easeInOutSine', =>
        @visible = true
        @load()


  resize: (keepVisible) ->
    # TODO: resizing is a bit shitty when the modal has panes and is scrollable
    visibility = if keepVisible then 'visible' else 'hidden'

    viewportHeight = $(window).height()
    titleHeight = @titleElement.outerHeight()

    width = @contentElement.outerWidth()

    @contentPane.css({height: 'auto'}) if @contentPane
    @contentElement.css({height: 'auto', visibility: visibility, display: 'block'})

    height = @contentElement.outerHeight() + titleHeight

    width = @minWidth if width < @minWidth
    height = viewportHeight - 20 if height > viewportHeight - 20 || @options.fullHeight

    @element.stop().animate {left: ($(window).width() - width) / 2, width: width, height: height}, 200, 'easeInOutSine', =>
      @contentElement.css({visibility: 'visible', display: 'block'})
      if @contentPane.length
        @contentElement.css({height: height - titleHeight, overflow: 'visible'})
        controlHeight = if @contentControl.length then @contentControl.outerHeight() else 0
        @contentPane.css({height: height - titleHeight - controlHeight - 40})
        @contentPane.find('.mercury-modal-pane').css({width: width - 40})
      else
        @contentElement.css({height: height - titleHeight, overflow: 'auto'})

  position: ->
    viewportWidth = $(window).width()
    viewportHeight = $(window).height()

    @contentPane.css({height: 'auto'}) if @contentPane
    @contentElement.css({height: 'auto'})
    @element.css({width: 'auto', height: 'auto', display: 'block', visibility: 'hidden'})

    width = @element.width()
    height = @element.height()

    width = @minWidth if width < @minWidth
    height = viewportHeight - 20 if height > viewportHeight - 20 || @options.fullHeight

    titleHeight = @titleElement.outerHeight()
    if @contentPane && @contentPane.length
      @contentElement.css({height: height - titleHeight, overflow: 'visible'})
      controlHeight = if @contentControl.length then @contentControl.outerHeight() else 0
      @contentPane.css({height: height - titleHeight - controlHeight - 40})
      @contentPane.find('.mercury-modal-pane').css({width: width - 40})
    else
      @contentElement.css({height: height - titleHeight, overflow: 'auto'})

    @element.css {
      left: (viewportWidth - width) / 2
      width: width,
      height: height,
      display: if @visible then 'block' else 'none',
      visibility: 'visible'
    }


  update:  ->
    @reset()
    @resize()
    @load()


  load: ->
    @element.addClass('loading')
    @setTitle()
    $.ajax @url, {
      success: (data) => @loadContent(data)
      error: =>
        @hide()
        alert("Mercury was unable to load #{@url} for the modal.")
    }


  loadContent: (data, options) ->
    @options = options || @options
    @setTitle()
    @loaded = true
    @element.removeClass('loading')
    @contentElement.html(data)
    @contentElement.css({display: 'none', visibility: 'hidden'})

    # for complex modal content, we provide panes and controls
    @contentPane = @element.find('.mercury-modal-pane-container')
    @contentControl = @element.find('.mercury-modal-controls')

    @options.afterLoad.call(@) if @options.afterLoad
    if @options.handler && Mercury.modalHandlers[@options.handler]
      Mercury.modalHandlers[@options.handler].call(@)

    @resize()


  setTitle: ->
    @titleElement.find('span').html(@options.title)


  reset: ->
    @titleElement.find('span').html('')
    @contentElement.html('')


  hide: ->
    Mercury.trigger('focus:frame')
    @element.hide()
    @overlay.hide()
    @reset()

    @visible = false

}