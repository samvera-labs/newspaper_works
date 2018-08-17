/*jshint browser: true, nomen: false, eqnull: true, es5:true, trailing:true */

(function () {
  "use strict";
  var work_form = $("form[data-behavior='work-form']"),
      Autocomplete = require('hyrax/autocomplete'),
      LinkedData = require('hyrax/autocomplete/linked_data');
  
  function patch_autocomplete() {
    var method = Autocomplete.prototype.setup;
    if (!window._autocomplete_patched) {
      Autocomplete.prototype.setup = function (element, fieldName, url) {
        // defer to original method for relevant BasicMetadata fields:
        var defer = ['based_near', 'language'],
            autourl = element.attr('data.autocomplete-url'),
            declared = (element.attr('data-autocomplete') === fieldName),
            ld = (declared && autourl && autourl.indexOf('authorities') !== -1);
        if (declared && defer.indexOf(fieldName) == -1) {
          new LinkedData(element, url);
          console.log('Using patched autocomplete for field', fieldName);
        } else {
          method(element, fieldName, url); 
        }
      };
      window._autocomplete_patched = true;
    }
  }

  function reinitialize_autocomplete() {
    $("input[data-autocomplete]").each(function() {
      var input = $(this),
          autocomplete;
      if (input.data('ui-autocomplete') !== undefined) {
        // remove jqueryui autocomplete previously set up:
        input.autocomplete("destroy");
      }
      // re-initialize Hyrax autocomplete:
      autocomplete = new Autocomplete();
      autocomplete.setup(
        input,
        input.attr('data-autocomplete'),
        input.attr('data-autocomplete-url')
      );
    });
  }

  if (work_form.length && work_form.attr('id').indexOf('newspaper_') != -1) {
    patch_autocomplete();
    reinitialize_autocomplete();
  }
}());

