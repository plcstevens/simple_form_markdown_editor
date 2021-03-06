# https://github.com/jquery-boilerplate/jquery-boilerplate/
do ($ = jQuery, window, document) ->

  pluginName = 'simple_form_markdown_editor_tabs'
  defaults =
    debug: false

  # ---------------------------------------------------------------------

  class Plugin
    constructor: (@element, options) ->
      @settings = $.extend {}, defaults, options

      @$element = $(@element)

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->
      console.log 'init' if @settings.debug

      @get_edit_tab().addClass('active')

      @get_tab_lis().on 'click', (e) =>
        @get_tab_lis().removeClass('active')
        $(e.currentTarget).addClass('active')
        @$element.attr('data-show', $(e.currentTarget).data('command'))

      @get_preview_tab().on 'click', (e) =>
        $.ajax(
          context: @element
          type: 'POST'
          url: @$element.attr('data-preview-path')
          data:
            _method: 'PUT'
            text: @get_textarea().val() || ''
            options: @get_textarea_options()
          success: (html) =>
            @get_preview_div().html(html) or "<p>#{@get_nothing_to_preview_text()}</p>"
        )

    # ---------------------------------------------------------------------

    get_textarea: -> @get_editor_div().find('textarea')
    get_preview_div: -> @$element.find('div.preview')
    get_editor_div: -> @$element.find('div.editor')
    get_header: -> @$element.find('div.header:first')
    get_tabs_ul: -> @get_header().find('ul.tabs')
    get_tab_lis: -> @get_tabs_ul().children('li')
    get_preview_tab: -> @get_tab_lis().filter('.preview')
    get_edit_tab: -> @get_tab_lis().filter('.edit')
    get_nothing_to_preview_text: -> @get_preview_div().data('nothing-to-preview-text') or "Nothing to preview."
    get_textarea_options: -> @$element.data('options')

  # ---------------------------------------------------------------------

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations and allowing any
  # public function (ie. a function whose name doesn't start
  # with an underscore) to be called via the jQuery plugin,
  # e.g. $(element).defaultPluginName('functionName', arg1, arg2)

  $.fn[pluginName] = (options) ->
    args = arguments
    if options is `undefined` or typeof options is "object"
      @each ->
        $.data this, "plugin_" + pluginName, new Plugin(this, options)  unless $.data(this, "plugin_" + pluginName)

    else if typeof options is "string" and options[0] isnt "_" and options isnt "init"
      returns = undefined
      @each ->
        instance = $.data(this, "plugin_" + pluginName)
        returns = instance[options].apply(instance, Array::slice.call(args, 1))  if instance instanceof Plugin and typeof instance[options] is "function"
        $.data this, "plugin_" + pluginName, null  if options is "destroy"

      (if returns isnt `undefined` then returns else this)

# =====================================================================

$ -> $('div.simple_form_markdown_editor').simple_form_markdown_editor_tabs()
