(function() {
  var $, ElementPicker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  ElementPicker = (function() {
    function ElementPicker() {
      this.keyDown = __bind(this.keyDown, this);
      this.mouseUp = __bind(this.mouseUp, this);
      this.mouseMove = __bind(this.mouseMove, this);
      this.pasterCallback = __bind(this.pasterCallback, this);
      this.hitSelection = __bind(this.hitSelection, this);
      this.paste = __bind(this.paste, this);      this.highlightedClass = 'elementPickerSelected';
      this.prevKey = 37;
      this.nextKey = 39;
      this.childKey = 40;
      this.parentKey = 38;
      this.selectKey = 13;
      this.quitKey = 27;
      this.state = 'OFF';
      this.copyPasteServer = "http://localhost:4567";
      this.shouldPaste = false;
      this.pasteLocationOptions = "<div>\n  <form id='pasterForm'>\n    <input id='pastePrepend' class='pasterBtn' type='submit' value='Prepend' />\n    <input id='pasteAppend' class='pasterBtn' type='submit' value='Append' />\n    <input id='pasteBefore' class='pasterBtn' type='submit' value='Place Before' />\n    <input id='pasteAfter' class='pasterBtn' type='submit' value='Place After' />\n  </form>\n</div>";
      this.border = $('<div id=\'floatingBorder\' class=\'floatingBorder\' />');
      this.border.css({
        display: 'none',
        position: 'absolute',
        zIndex: 65000,
        background: 'rgba(255,0,0,0.3)'
      });
      this.pasterElem = null;
      this.border.hide();
      this.selected = $();
      this.last = new Date;
      $('html').append(this.border);
    }
    ElementPicker.prototype.paste = function() {
      var callback;
      callback = function() {};
      return this.enablePicker(callback, true);
    };
    ElementPicker.prototype.enablePicker = function(callback, shouldPaste) {
      if (this.state === 'OFF') {
        this.state = 'ON';
        this.callback = callback;
        if ((shouldPaste != null) && shouldPaste === true) {
          this.shouldPaste = true;
        }
        this.select($('body'));
        $('html').keydown(this.keyDown).keyup(this.keyUp);
        $('html').mousemove(this.mouseMove);
        return $('html').mouseup(this.mouseUp);
      }
    };
    ElementPicker.prototype.disablePicker = function() {
      if (this.state === 'ON') {
        this.state = 'OFF';
        return this.clearSelection();
      }
    };
    ElementPicker.prototype.keyUp = function(event) {
      return $('html').data('pressed', false);
    };
    ElementPicker.prototype.clearSelection = function() {
      this.border.hide();
      return this.selected = $();
    };
    ElementPicker.prototype.select = function(element) {
      var offset;
      this.clearSelection();
      offset = element.offset();
      this.border.css({
        width: element.outerWidth() - 1,
        height: element.outerHeight() - 1,
        left: offset.left,
        top: offset.top
      });
      this.border.show();
      return this.selected = element;
    };
    ElementPicker.prototype.getSelection = function() {
      return this.selected;
    };
    ElementPicker.prototype.hitSelection = function(node) {
      var html;
      if (this.shouldPaste) {
        this.pasterElem = node;
        this.disablePicker();
        window.ec.callout(this.pasterElem, "Where do you want to paste?", this.pasteLocationOptions);
        return $(".pasterBtn").click(__bind(function(event) {
          window.ec.close(this.pasterElem);
          event.preventDefault();
          return this.pasterCallback(event);
        }, this));
      } else {
        html = node.clone().wrap('<div></div>').parent().html();
        this.copy(html);
        if (this.callback != null) {
          return this.callback(node);
        }
      }
    };
    ElementPicker.prototype.copy = function(text) {
      if (typeof text === "undefined") {
        this.enablePicker();
        return this.shouldPaste = false;
      } else {
        console.log("copy: " + text);
        $.getJSON(this.copyPasteServer + "/copy", {
          'data': text
        });
        return this.disablePicker();
      }
    };
    ElementPicker.prototype.pasterCallback = function(event) {
      return $.getJSON(this.copyPasteServer + "/paste?callback=?", __bind(function(ret) {
        switch (event.target.id) {
          case "pastePrepend":
            this.pasterElem.prepend($(ret));
            break;
          case "pasteAppend":
            this.pasterElem.append($(ret));
            break;
          case "pasteBefore":
            this.pasterElem.before($(ret));
            break;
          case "pasteAfter":
            this.pasterElem.after($(ret));
            break;
          default:
            alert("Don't know where to put" + ret);
        }
        return this.pasterElem = null;
      }, this));
    };
    ElementPicker.prototype.mouseMove = function(event) {
      var el, now;
      if (this.state === "OFF") {
        return;
      }
      el = event.target;
      now = new Date;
      if (now - this.last < 25) {
        return;
      }
      this.last = now;
      if (el === document.body) {
        this.clearSelection();
      } else if (el.id === 'floatingBorder') {
        this.border.hide();
        el = document.elementFromPoint(event.clientX, event.clientY);
      }
      el = $(el);
      return this.select(el);
    };
    ElementPicker.prototype.mouseUp = function(event) {
      var n;
      if (this.state === "OFF") {
        return;
      }
      this.state = "OFF";
      n = this.getSelection();
      this.clearSelection();
      this.hitSelection(n);
      return event.preventDefault();
    };
    ElementPicker.prototype.keyDown = function(event) {
      var data, n;
      if (this.state === "OFF") {
        return;
      }
      data = $('html').data();
      if (!data['pressed']) {
        data['pressed'] = true;
        switch (event.which) {
          case this.selectKey:
            n = this.getSelection();
            this.clearSelection();
            this.hitSelection(n);
            event.preventDefault();
            break;
          case this.nextKey:
            n = this.getSelection().next();
            if (n.length > 0) {
              this.select(n);
            }
            event.preventDefault();
            break;
          case this.prevKey:
            n = this.getSelection().prev();
            if (n.length > 0) {
              this.select(n);
            }
            event.preventDefault();
            break;
          case this.childKey:
            n = this.getSelection().children();
            if (n.length > 0) {
              this.select($(n[0]));
            }
            event.preventDefault();
            break;
          case this.parentKey:
            n = this.getSelection().parent();
            if (n.length > 0) {
              this.select(n);
            }
            event.preventDefault();
            break;
          case this.quitKey:
            this.disablePicker();
            return event.preventDefault();
        }
      }
    };
    return ElementPicker;
  })();
  window.ep = new ElementPicker();
}).call(this);
