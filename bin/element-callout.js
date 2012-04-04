(function() {
  var $, ElementCallout;
  $ = jQuery;
  ElementCallout = (function() {
    function ElementCallout() {}
    ElementCallout.prototype.callout = function(node, title, body) {
      $(node).popover({
        'title': title,
        'content': body,
        'trigger': 'manual'
      });
      return $(node).popover('show');
    };
    ElementCallout.prototype.close = function(node) {
      return $(node).popover('hide');
    };
    return ElementCallout;
  })();
  window.ec = new ElementCallout();
}).call(this);
