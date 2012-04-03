(function() {
  var $, ElementPicker;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  $('head').append("<style>\n  .floatingBorder {\n    border: 2px solid red !important;\n    position: absolute;\n    z-order: 10000;\n  }\n</style>");
  ElementPicker = (function() {
    function ElementPicker() {
      this.keyDown = __bind(this.keyDown, this);      this.highlightedClass = "elementPickerSelected";
      this.prevKey = 37;
      this.nextKey = 39;
      this.childKey = 40;
      this.parentKey = 38;
      this.selectKey = 13;
      this.state = "OFF";
      this.border = $("<div id='elementPickerBorder' class='floatingBorder'></div>");
      this.border.hide();
      this.selected = $();
      $('html').append(this.border);
    }
    ElementPicker.prototype.enablePicker = function(callback) {
      if (this.state === "OFF") {
        this.state = "ON";
        this.callback = callback;
        this.select($('body'));
        $('body').keydown(this.keyDown);
        return $('body').keyup(this.keyUp);
      }
    };
    ElementPicker.prototype.disablePicker = function() {
      if (this.state === "ON") {
        this.state = "OFF";
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
      this.border.offset(element.offset());
      this.border.width(element.width());
      this.border.height(element.height());
      this.clearSelection();
      this.border.show();
      element.addClass(this.highlightedClass);
      return this.selected = element;
    };
    ElementPicker.prototype.getSelection = function() {
      return this.selected;
    };
    ElementPicker.prototype.hitSelection = function(node) {
      return this.callback(node);
    };
    ElementPicker.prototype.keyDown = function(event) {
      var data, n;
      data = $('html').data();
      if (!data["pressed"]) {
        data["pressed"] = true;
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
        }
      }
    };
    return ElementPicker;
  })();
  window.ep = new ElementPicker();
}).call(this);