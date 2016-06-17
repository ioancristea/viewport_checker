// Copyright (c) 2016, Ioan Cristea. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library viewport_checker;

import 'dart:html';

class viewportChecker {
  // Properties
  ElementList<Element> _elem;
  Map boxSize;
  String scrollElem;

  // Default options
  Map options = {
    'classToAdd': 'visible',
    'classToRemove': 'invisible',
    'classToAddForFullView': 'full-visible',
    'removeClassAfterAnimation': false,
    'offset': 100,
    'repeat': false,
    'invertBottomOffset': true,
    'callbackFunction': (Element elem, String action) => {},
    'scrollHorizontal': false,
    'scrollBox': window
  };

  // Constructor
  viewportChecker(String selector, Map userOptions) {
    // Rewrite options with user options
    options.addAll(userOptions);

    // Cache some properties
    _elem = querySelectorAll(selector);
    boxSize = {'height': options['scrollBox'].innerHeight, 'width': options['scrollBox'].innerWidth};
    scrollElem = (window.navigator.userAgent.toLowerCase().indexOf('webkit') != -1 || window.navigator.userAgent.toLowerCase().indexOf('windows phone') != -1) ? 'body' : 'html';

    // Always load on window load and scroll
    options['scrollBox'].addEventListener('load', checkElements);
    options['scrollBox'].addEventListener('scroll', checkElements);

    // On resize change the height var
    window.addEventListener('resize', (event) {
      boxSize = {'height': options['scrollBox'].innerHeight, 'width': options['scrollBox'].innerWidth };
      checkElements(null);
    });

    // Initial check
    checkElements(null);
  }

  checkElements(event) {
    var viewportStart, viewportEnd;

    // Set some vars to check with
    if(!options['scrollHorizontal']) {
      viewportStart = querySelector(scrollElem).scrollTop;
      viewportEnd = viewportStart + boxSize['height'];
    } else {
      viewportStart = querySelector(scrollElem).scrollLeft;
      viewportEnd = viewportStart + boxSize['width'];
    }

    // Check each element from selector
    _elem.forEach((Element element) {
      Map attrOptions = {};
      Map objOptions = {};

      //  Get any individual attribution data
      if(element.dataset['vp-add-class'] != null)
        attrOptions['classToAdd'] = element.dataset['vp-add-class'];

      if(element.dataset['vp-remove-class'] != null)
        attrOptions['classToRemove'] = element.dataset['vp-remove-class'];

      if(element.dataset['vp-add-class-full-view'] != null)
        attrOptions['classToAddForFullView'] = element.dataset['vp-add-class-full-view'];

      if(element.dataset['vp-keep-add-class'] != null)
        attrOptions['removeClassAfterAnimation'] = element.dataset['vp-keep-add-class'];

      if(element.dataset['vp-offset'] != null)
        attrOptions['offset'] = element.dataset['vp-offset'];

      if(element.dataset['vp-repeat'] != null)
        attrOptions['repeat'] = element.dataset['vp-repeat'];

      if(element.dataset['vp-scrollHorizontal'] != null)
        attrOptions['scrollHorizontal'] = element.dataset['vp-scrollHorizontal'];

      if(element.dataset['vp-invertBottomOffset'] != null)
        attrOptions['scrollHorizontal'] = element.dataset['vp-invertBottomOffset'];

      // Extend objOptions with data attributes and default options
      objOptions.addAll(options);
      objOptions.addAll(attrOptions);

      // If class already exists; quit
      if (element.dataset['vp-animated'] == true && !objOptions['vp-repeat']){
        return;
      }

      // Check if the offset is percentage based
      if (objOptions['offset'].toString().indexOf("%") > 0)
        objOptions['offset'] = (int.parse(objOptions['offset']) / 100) * boxSize['height'];

      // Get the raw start and end positions
      var rawStart = (!objOptions['scrollHorizontal']) ? element.offset.top : element.offset.left;
      var rawEnd = (!objOptions['scrollHorizontal']) ? rawStart + element.clientHeight : rawStart + element.clientWidth;

      // Add the defined offset
      var elemStart = rawStart.round() + objOptions['offset'],
          elemEnd = (!objOptions['scrollHorizontal']) ? elemStart + element.clientHeight : elemStart + element.clientWidth;

      if (objOptions['invertBottomOffset'])
        elemEnd -= (objOptions['offset'] * 2);

      // Add class if in viewport
      if ((elemStart < viewportEnd) && (elemEnd > viewportStart)) {

        element.classes.remove(objOptions['classToRemove']);
        element.classes.add(objOptions['classToAdd']);

        // Do the callback function. Callback will send the Element object as parameter
        objOptions['callbackFunction'](element, "add");

        // Check if full element is in view
        if (rawEnd <= viewportEnd && rawStart >= viewportStart)
          element.classes.add(objOptions['classToAddForFullView']);
        else
          element.classes.remove(objOptions['classToAddForFullView']);

        // Set element as already animated
        element.dataset['vp-animated'] = 'true';

        // TODO
//        if (objOptions['removeClassAfterAnimation']) {
//          element.addEventListener('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', (event){
//            element.classes.remove(objOptions['classToAdd']);
//          });
//        }

        // Remove class if not in viewport and repeat is true
      } else if (element.classes.contains(objOptions['classToAdd']) && element.dataset['vp-repeat'] != null){

        element.classes.remove(objOptions['classToAdd']);
        element.classes.remove(objOptions['classToAddForFullView']);

        // Do the callback function.
        objOptions['callbackFunction'](element, "remove");

        // Remove already-animated-flag
        element.dataset['vp-animated'] = 'false';
      }
    });
  }
}
