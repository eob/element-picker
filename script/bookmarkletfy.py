jsin = open("../bin/element-picker.js")
jsout = open("../bin/picker-bookmarklet.html", "w")

jsout.write("<html><body>")

script = ""

jQueryUrl = "http://jquery.com/src/jquery-latest.js"
testUrl = "http://localhost:1234/bin/test.js"
bootstrapJs = "http://localhost:1234/bin/bootstrap.min.js"
bootstrapCss = "http://localhost:1234/bin/bootstrap.min.css"
pickerUrl = "http://localhost:1234/bin/element-picker.js"

def makeCssImportString(url):
  ret =  "var s=document.createElement('link');"
  ret += "s.setAttribute('href','%s');" % url
  ret += "s.setAttribute('rel','stylesheet');"
  ret += "s.setAttribute('type','text/css');"
  ret += "document.getElementsByTagName('body')[0].appendChild(s);"
  return ret

def makeImportString(url):
  ret =  "var s=document.createElement('script');"
  ret += "s.setAttribute('src','%s');" % url
  ret += "document.getElementsByTagName('body')[0].appendChild(s);"
  return ret

def makeJqueryImportString(url, jquery):
  ret =  "if (typeof $ == 'undefined') {"
  ret += makeImportString(jquery)
  ret += "}"
  ret += makeImportString(url)
  return ret

def makeBookmarklet(js, name):
  return "<a href=\"javascript:%s\">%s</a>" % (js, name)

include = makeJqueryImportString(pickerUrl, jQueryUrl)
include += makeImportString(bootstrapJs)
include += makeCssImportString(bootstrapCss)

copy = include + "window.ep.copy();"
paste= include + "window.ep.paste();"

jsout.write(makeBookmarklet(copy, "Copy"))
jsout.write(makeBookmarklet(paste, "Paste"))

jsout.write("</body></html>")
jsout.close()

