# Copyright (c) 2012 Edward Benson
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

$ = jQuery
$('head').append("""
    <style>
      .floatingBorder {
        border: 2px solid red !important;
        position: absolute;
        z-order: 10000;
      }
    </style>
""")

class ElementPicker
  constructor: () ->
    @highlightedClass = "elementPickerSelected"
    @prevKey = 37
    @nextKey = 39
    @childKey = 40
    @parentKey = 38
    @selectKey = 13
    @state = "OFF"
    @border = $("<div id='elementPickerBorder' class='floatingBorder'></div>")
    @border.hide()
    @selected = $()
    $('html').append(@border)
   
  enablePicker: (callback) ->
    if @state == "OFF"
      @state = "ON"
      @callback = callback
      @.select($('body'))
      $('body').keydown(@keyDown)
      $('body').keyup(@keyUp)

  disablePicker: () ->
    if @state == "ON"
      @state = "OFF"
      @.clearSelection()

  keyUp: (event) ->
    $('html').data('pressed', false)

  clearSelection: () ->
    @border.hide()
    @selected = $()
 
  select: (element) ->
    @border.offset(element.offset())
    @border.width(element.width())
    @border.height(element.height())
    @.clearSelection()
    @border.show()
    element.addClass(@highlightedClass)
    @selected = element

  getSelection: () ->
    @selected

  hitSelection: (node) ->
    @callback(node)

  keyDown: (event) =>
    data = $('html').data()
    if not data["pressed"]
      data["pressed"] = true
      switch event.which
        when @selectKey
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
        else

window.ep = new ElementPicker()
