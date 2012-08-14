# Copyright (c) 2012 Edward Benson
#
# **ElementPicker** is a simple Javascript-based DOM node selection 
# tool. It supports both keyboard and mouse navigation.
#
#### License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Preamble
$ = jQueryDss
module = (name) ->
  window[name] = window[name] or {}

# Ensure the DSS namespace
module 'DSS'

#### Usage:
#
# window.ElementPicker.pick(callback, opts)
# 
# - callback is a function taking a single argument, the element picked
# - options are the following:
#     
# *  **autoClear** (default: `true`). Clear selection when pick occurs. Manual
#    clearing can be done with `window.ElementPicker.clearSelection()`
#
#  
class ElementPicker
  constructor: (options) ->
    @opts = $.extend {}, {'autoClear':true}, options
    @highlightedClass = 'elementPickerSelected'
    @prevKey = 37 #Left
    @nextKey = 39 #Right
    @childKey = 40 #Down
    @parentKey = 38 #Up
    @selectKey = 13 #Enter
    @quitKey = 27 #ESC
    @state = 'OFF'
    @copyPasteServer = "http://localhost:4567"
    @shouldPaste = no
    #@paster = $('<div class=\'epPasteWidget\' />')
    #@paster.css({
    #  display: 'none',
    #  position: 'absolute',
    #  zIndex: 65001,
    #  background: 'rgba(0,0,0,0.7)',
    #  border: '1px solid black'
    #})
    #@pasteLocationOptions = """
    #  <div>
    #    <h3>Paste</h3>
    #    <input type="checkbox" id="pasteContent" />Content</div>
    #    <input type="checkbox" id="pasteStyle" />Style</div>
    #    <h3>Insert Location</h3>
    #    <div style="padding-left: 15px; float: left; margin-right: 5px;">
    #    <img src="/bin/where.png" />
    #    </div>
    #    <div style="margin-left: 5px">
    #      <div style="margin-top:9px">
    #        <input type="radio" style="margin-right: 3px" id="pasteBefore" name="pasteWhere" />Before
    #      </div>
    #      <div style="margin-top:18px">
    #        <input type="radio" style="margin-right: 3px" id="pastePrepend" name="pasteWhere" />Prepend<br />
    #      </div>
    #      <div style="margin-top:-1px">
    #        <input type="radio" style="margin-right: 3px" id="pasteReplace" name="pasteWhere" />Replace<br />
    #      </div>
    #      <div style="margin-top:0px">
    #        <input type="radio" style="margin-right: 3px" id="pasteAppend" name="pasteWhere" />Append<br />
    #      </div>
    #      <div style="margin-top:13px">
    #        <input type="radio" style="margin-right: 3px" id="pasteAfter" name="pasteWhere" />After
    #      </div>
    #    </div>
    #    <button class="btn btn-primary pasterBtn">Paste</button><button class="btn pasteCancelBtn">Cancel</button>
    #  </div>
    #"""
    @border = $('<div id=\'floatingBorder\' class=\'floatingBorder\' />')
    @border.css({
      display: 'none',
      position: 'absolute',
      zIndex: 65000,
      background: 'rgba(255,0,0,0.3)'
    })
    @pasterElem = null
    @border.hide()
    @selected = $()
    @last = new Date
    $('html').append(@border)

  pick: (callback, options) =>
    @opts = $.extend {}, {'autoClear':true}, options
    if @state == 'OFF'
      @state = 'ON'
      @callback = callback
      @.select($('body'))
      $('html').keydown(@keyDown).keyup(@.keyUp)
      $('html').mousemove(@.mouseMove)
      $('html').mouseup(@.mouseUp)
    else
      console.log("Picker error: tried to pick but picker is already active")

  #paste: () =>
  #  callback = () ->
  #  @.enablePicker(callback, yes)

  #enablePicker: (callback) ->
  #  if @state == 'OFF'
  #    @state = 'ON'
  #    @callback = callback
  #    if shouldPaste? and shouldPaste == yes
  #      @shouldPaste = yes
  #    @.select($('body'))
  #    $('html').keydown(@keyDown).keyup(@.keyUp)
  #    $('html').mousemove(@.mouseMove)
  #    $('html').mouseup(@.mouseUp)

  disablePicker: () ->
    if @state == 'ON'
      @state = 'OFF'
      @.clearSelection()

  keyUp: (event) ->
    $('html').data('pressed', false)

  clearSelection: () ->
    @border.hide()
    @selected = $()
 
  select: (element) ->
    @.clearSelection()
    offset = element.offset()
    @border.css({
     width:  element.outerWidth()  - 1, 
     height: element.outerHeight() - 1, 
     left:   offset.left, 
     top:    offset.top 
    });
    @border.show(); 
    @selected = element

  getSelection: () ->
    @selected

  hitSelection: (node) =>
    if @opts.autoClear
      @.clearSelection()
    @callback(node)
    #if @shouldPaste
    #  @pasterElem = node
    #  @state = "OFF"
    #  window.ec.callout(@pasterElem, "Where do you want to paste?", @pasteLocationOptions)
    #  $(".pasterBtn").click (event) =>
    #    window.ec.close(@pasterElem)
    #    @.clearSelection()
    #    event.preventDefault()
    #    @.pasterCallback(event)
    #  $(".pasteCancelBtn").click (event) =>
    #    @.clearSelection()
    #    window.ec.close(@pasterElem)
    #    event.preventDefault()
    #else
    #  html = node.clone().wrap('<div></div>').parent().html()
    #  @.copy(html)
    #  if @callback?
    #    @callback(node)

  #copy: (text) ->
  #  if typeof text == "undefined"
  #    @.enablePicker()
  #    @shouldPaste = no
  #  else
  #    console.log("copy: " + text)
  #    $.getJSON(@copyPasteServer + "/copy", {'data':text})
  #    @.disablePicker()

  #pasterCallback: (event) =>
  #  $.getJSON(@copyPasteServer + "/paste?callback=?", (ret) =>
  #    switch $("input:radio[name=pasteWhere]:checked").data("pasteLoc")
  #      when "pasteReplace"
  #        @pasteElem.replace($(ret))
  #        break
  #      when "pastePrepend"
  #        @pasterElem.prepend($(ret))
  #        break
  #      when "pasteAppend"
  #       @pasterElem.append($(ret))
  #       break
  #      when "pasteBefore"
  #        @pasterElem.before($(ret))
  #        break
  #      when "pasteAfter"
  #        @pasterElem.after($(ret))
  #        break
  #      else
  #        alert("Don't know where to put" + ret)
  #    @pasterElem = null
  #  )

  mouseMove: (event) =>
    if @state == "OFF"
      return
    el = event.target
    now = new Date
    return if now-@last < 25 # Only poll > 25ms increments
    @last = now
    if el == document.body
      @.clearSelection()
    else if el.id== 'floatingBorder'
      @border.hide()
      el = document.elementFromPoint(event.clientX, event.clientY)
    el = $(el)
    @.select(el)

  mouseUp: (event) =>
    if @state == "OFF"
      return
    @state = "OFF"
    n = @.getSelection()
    @.hitSelection(n)
    event.preventDefault()

  keyDown: (event) =>
    if @state == "OFF"
      return
    data = $('html').data()
    if not data['pressed']
      data['pressed'] = true
      switch event.which
        when @selectKey
          @state = "OFF"
          n = @.getSelection()
          @.clearSelection()
          @.hitSelection(n)
          event.preventDefault()
          break
        when @nextKey
          n = @.getSelection().next()
          if n.length > 0
            @.select(n)
          event.preventDefault()
          break
        when @prevKey
          n = @.getSelection().prev()
          if n.length > 0
            @.select(n)
          event.preventDefault()
          break
        when @childKey
          n = @.getSelection().children()
          if n.length > 0
            @.select($(n[0]))
          event.preventDefault()
          break
        when @parentKey
          n = @.getSelection().parent()
          if n.length > 0
            @.select(n)
          event.preventDefault()
          break
        when @quitKey
          @.disablePicker()
          event.preventDefault()
        else

DSS.ElementPicker = new ElementPicker()
