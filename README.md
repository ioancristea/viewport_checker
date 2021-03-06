# viewport_checker

A library for Dart who check if elements from page are in viewport.

## Simple Usage
```dart
new viewportChecker('.my-element-to-check', {
    'classToAdd': 'visible', // Class to add to the elements when they are visible,
    'classToAddForFullView': 'full-visible', // Class to add when an item is completely visible in the viewport
    'classToRemove': 'invisible', // Class to remove before adding 'classToAdd' to the elements
    'removeClassAfterAnimation': false, // Remove added classes after animation has finished
    'offset': [100 OR 10%], // The offset of the elements (let them appear earlier or later). This can also be percentage based by adding a '%' at the end
    'invertBottomOffset': true, // Add the offset as a negative number to the element's bottom
    'repeat': false, // Add the possibility to remove the class if the elements are not visible
    'callbackFunction': function(elem, action){}, // Callback to do after a class was added to an element. Action will return "add" or "remove", depending if the class was added or removed
    'scrollHorizontal': false // Set to true if your website scrolls horizontal instead of vertical.
});
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ioancristea/viewport_checker/issues
