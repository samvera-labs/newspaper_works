/*jshint browser: true, nomen: false, eqnull: true, es5:true, trailing:true */

(function () {
  "use strict";
  
  function patch_autocomplete() {
    var method = require('hyrax/autocomplete').prototype.setup;
    if (!window._autocomplete_patched) {
      require('hyrax/autocomplete').prototype.setup = function (element, fieldName, url) {
        var defer = ['based_near'],
            autourl = element.attr('data.autocomplete-url'),
            declared = (element.attr('data-autocomplete') === fieldName),
            ld = (declared && autourl && autourl.indexOf('authorities') !== -1);
        if (declared && defer.indexOf(fieldName) == -1) {
          new LinkedData(element, url);
          console.log('Patched autocomplete for field', fieldName);
        } else {
          method(element, fieldName, url); 
        }
      };
      window._autocomplete_patched = true;
    }
  }

  var work_form = $("form[data-behavior='work-form']");
  if (work_form.length && work_form.attr('id').indexOf('newspaper_') != -1) {
    patch_autocomplete();
  }
}());

