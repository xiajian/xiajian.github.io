---
layout: post
title: JQuery插件：cluetip
---

## 缘起
----

要在网站上做一个鼠标移动到超链接上，弹出提示框的效果。一开始同事自己写了个cardFloat插件，浮动的位置判断起来太蛋疼，于是他找个了插件clueTip，说效果类似，让我试试怎么从后台将数据放上去。取数据这种事就的要用Ajax，研究着将Ajax请求同cluetip插件结合起来。

## 概述
----

clueTip是一个jQuery的Tooltip插件，针对任何特定的元素(jQuery的包装集)的hover或者点击动作，可以显示高度定制的tooltip。cluetip默认使用元素的title属性作为Tooltip的头。

Github地址:<https://github.com/kswedberg/jquery-cluetip>，文档地址:<http://plugins.learningjquery.com/cluetip> 

## 快速上手
----

只需两部，就可显示基本的clueTip。
第一步: 在需要调用clueTip的页面添加引入js文件。
{% highlight javascript %}
    <script src="jquery.js" type="text/javascript"></script> <!--必须-->
    <script src="jquery.cluetip.js" type="text/javascript"></script><!--必须-->
    <script src="jquery.hoverIntent.js" type="text/javascript"></script> <!--可选-->
    <link rel="stylesheet" href="jquery.cluetip.css" type="text/css" /><!--可选-->
{% endhighlight %}
> 为了使用cluetip,必须引入Jquery  

第二步: 设置元素的属性,并在特定元素上调用cluetip
{% highlight javascript %}
    <script type="text/javascript">
    $(document).ready(function() {
      $('a.tips').cluetip();
    
      $('#houdini').cluetip({
        splitTitle: '|', // use the invoking element's title attribute to populate the clueTip...
                         // ...and split the contents into separate divs where there is a "|"
        showTitle: false // hide the clueTip's heading
      });
    });
    </script>
    <!-- use ajax/ahah to pull content from fragment.html: -->
    <p><a class="tips" href="fragment.html" rel="fragment.html">show me the cluetip!</a></p>
    
    <!-- use title attribute for clueTip contents, but don't include anything in the clueTip's heading -->
    <p><a id="houdini" href="houdini.html" title="|Houdini was an escape artist.|He was also adept at prestidigitation.">Houdini</a></p>
{% endhighlight %}
默认情况下，clueTip使用rel属性通过AHAH(Asychronous HTML and HTTP,利用JavaScript通过XHR动态获取html,比Ajax更简单)获取内容并加载到tooltip中。

## clueTip插件的特性
----
clueTip中包含很多的特性,列出如下:

- 多个内容源
- 智能定位
- 灵活的行为
- 多变的样式

### Multiple Content Sources

The contents of the clueTip can come from one of these sources:

    a separate file, via AHAH / AJAX
    an element on the same page, typically hidden
    the title attribute, parsed by a user-defined delimiter (if the "splitTitle" option is set). The text before the first delimiter becomes the clueTip title, and the rest of the text parts are placed in <div class="split-body"></div> elements and appended to the clueTip body
    the return value of a function referenced in the first argument of .cluetip().

### Smart Positioning
The clueTip Plugin has 4 positioning modes, which you can change via the "positionBy" option.

    positionBy: 'auto' (default)
        places the tooltip just to the right of the invoking element, but...
        if there is not enough room for the tooltip to be fully visible between the right edge of the invoking element and the right edge of the browser window, switches from the right side to the left side, but...
        if the invoking element is too close to the bottom edge of the browser window, adjusts the tooltip upwards until the whole tooltip is visible, but...
        if the tooltip is taller than the window (i.e. the viewable area), adjusts the tooltip back down until the tooltip's top is at the top edge of the browser window, but...
        position if the invoking element is so wide that the tooltip can't completely fit to the left or the right of it, places the tooltip to the right or left of the mouse, but...
        if the tooltip itself can't fit to the right or left of the mouse position, places the tooltip below the mouse position (centered horizontal if enough room), but...
        if (a) there isn't enough room below without being cut off, and (b) there is enough room between the top of the viewable area and the mouse, puts the tooltip above the mouse position
    positionBy: 'mouse'
        places the tooltip to the right of the mouse position, but...
        if there is not enough room to the right, places the tooltip to the left of the mouse position, but...
        if the tooltip itself can't fit to the right or left of the mouse position, places the tooltip below the mouse position (centered horizontally if enough room), but...
        if (a) there isn't enough room below without being cut off, and (b) there is enough room between the top of the viewable area and the mouse, puts the tooltip above the mouse position
    positionBy: 'bottomTop'
        places the tooltip below the mouse position (centered horizontally if enough room), but...
        if (a) there isn't enough room below without being cut off, and (b) there is enough room between the top of the viewable area and the mouse, puts the tooltip above the mouse position
    positionBy: 'fixed'
        places the tooltip in the same location relative to the invoking element, regardless of where it appears on the page.
        the fixed position can be adjusted by modifying the number of pixels in the topOffset and leftOffset options

### Flexible Behavior

    The clueTip takes advantage of Brian Cherne's hoverIntent plugin if it's available. (Just include it in a <script> tag if you want the clueTip to use it.)
    It can be activated on hover or on click.
    It can fade in, slide down, etc.
    It can close when the invoking element is moused out or when the tooltip is moused out or when the user clicks a "close" link.
    It can cache the results of ajax requests—or not.
    It can be turned off

### Variety of Styles

The clueTip Plugin comes with three themes: default, jTip, and rounded corners. Additional themes can be created by following the naming patterns in the stylesheet, jquery.cluetip.css. To apply one of the alternative themes, just indicate it in the cluetipClass option as 'jtip' or 'rounded'.

The "loading" image comes from this rule in the stylesheet:

#cluetip-waitimage {
      width: 43px;
      height: 11px;
      position: absolute;
      background-image: url(wait.gif);
    }

It can be turned off with the following option: waitImage: false

Other options that affect the visual appearance include hoverClass, arrows, dropShadow, and dropShadowSteps. Please see API / Options for more information.

## clueTip Plugin API / Options
----

The clueTip Plugin API provides two methods, with many options. It also provides a custom event for closing the tooltip programmatically

$.cluetip.setup(options)
    Global defaults for clueTips. Will apply to all calls to the clueTip plugin.
    {
          insertionType:    'appendTo', // how the clueTip is inserted into the DOM
                                        // possible values: 'appendTo', 'prependTo', 'insertBefore', 'insertAfter'
          insertionElement: 'body'      // where in the DOM the clueTip is to be inserted
    }

.cluetip(options)
    Displays a highly customizable tooltip via ajax (default) or local content or the title attribute of the invoking element 

{% highlight javascript %}
$.fn.cluetip.defaults = {  // default options; override as needed
    multiple:         false,    // Allow a new tooltip to be created for each .cluetip() call
    width:            275,      // The width of the clueTip
    height:           'auto',   // The height of the clueTip. more info below [1]
    cluezIndex:       97,       // Sets the z-index style property of the clueTip
    positionBy:       'auto',   // Sets the type of positioning. more info below [2]
    topOffset:        15,       // Number of px to offset clueTip from top of invoking element. more info below [3]
    leftOffset:       15,       // Number of px to offset clueTip from left of invoking element. more info below [4]
    local:            false,    // Whether to use content from the same page for the clueTip's body
                                // (treats the attribute used for accessing the tip as a jQuery selector,
                                // but only selects the first element if the selector matches more than one). more info below [5]
    hideLocal:        true,     // If local option is set to true, this determines whether local content
                                //  to be shown in clueTip should be hidden at its original location
    localPrefix:      null,       // string to be prepended to the tip attribute if local is true
    localIdSuffix:    null,     // string to be appended to the cluetip content element's id if local is true
    attribute:        'rel',    // the attribute to be used for fetching the clueTip's body content
    titleAttribute:   'title',  // the attribute to be used for fetching the clueTip's title
    splitTitle:       '',       // A character used to split the title attribute into the clueTip title and divs
                                // within the clueTip body. more info below [6]
    escapeTitle:      false,    // whether to html escape the title attribute
    showTitle:        true,     // show title bar of the clueTip, even if title attribute not set
    cluetipClass:     'default',// class added to outermost clueTip div in the form of 'cluetip-' + clueTipClass. more info below [7]
    hoverClass:       '',       // class applied to the invoking element onmouseover and removed onmouseout
    waitImage:        true,     // whether to show a "loading" img, which is set in jquery.cluetip.css
    cursor:           'help',
    arrows:           false,    // if true, displays arrow on appropriate side of clueTip. more info below [8]
    dropShadow:       true,     // set to false if you don't want the drop-shadow effect on the clueTip
    dropShadowSteps:  6,        // adjusts the size of the drop shadow
    sticky:           false,    // keep visible until manually closed
    mouseOutClose:    false,    // close when clueTip is moused out: false, 'cluetip', 'link', 'both'
    delayedClose:     50,        // close clueTip on a timed delay
    activation:       'hover',  // set to 'click' to force user to click to show clueTip
    clickThrough:     true,    // if true, and activation is not 'click', then clicking on a clueTipped link will take user to
                                // the link's href, even if href and tipAttribute are equal
    tracking:         false,    // if true, clueTip will track mouse movement (experimental)
    closePosition:    'top',    // location of close text for sticky cluetips; can be 'top' or 'bottom' or 'title'
    closeText:        'Close',  // text (or HTML) to to be clicked to close sticky clueTips
    truncate:         0,        // number of characters to truncate clueTip's contents. if 0, no truncation occurs

    // effect and speed for opening clueTips
    fx: {
                      open:       'show', // can be 'show' or 'slideDown' or 'fadeIn'
                      openSpeed:  ''
    },

    // settings for when hoverIntent plugin is used
    hoverIntent: {
                      sensitivity:  3,
                      interval:     50,
                      timeout:      0
    },

    // function to run just before clueTip is shown.
    // If the function returns false, the clueTip is NOT shown
    // It can take a single argument: the event object
    // Inside the function, this refers to the element that invoked the clueTip
    onActivate:       function(event) {return true;},

    // function to run just after clueTip is shown. It can take two arguments:
    // the first is a jQuery object representing the clueTip element;
    // the second a jQuery object represeting the clueTip inner div.
    // Inside the function, this refers to the element that invoked the clueTip
    onShow:           function(ct, ci){},

    // function to run just after clueTip is hidden. It can take two arguments:
    // the first is a jQuery object representing the clueTip element;
    // the second a jQuery object represeting the clueTip inner div.
    // Inside the function, this refers to the element that invoked the clueTip
    onHide:           function(ct, ci){},

    // whether to cache results of ajax request to avoid unnecessary hits to server
    ajaxCache:        true,

    // process data retrieved via xhr before it's displayed
    ajaxProcess:      function(data) {
                        data = data.replace(/<(script|style|title)[^<]+<\/(script|style|title)>/gm, '').replace(/<(link|meta)[^>]+>/g,'');
                        return data;
    },
    // can pass in standard $.ajax() parameters. Callback functions, such as beforeSend,
    // will be queued first within the default callbacks.
    ajaxSettings: {
      // error: function(ct, ci) { /* override default error callback */ },
      // beforeSend: function(ct, ci) { /* called first within default beforeSend callback */ },
      dataType: 'html'
    }
  };

$(document).trigger('hideCluetip')
    Hides any currently visible cluetip.


// example for how you might do this with touch devices
$('body').bind('touchstart', function(event) {
 event = event.originalEvent;
 var tgt = event.touches[0] && event.touches[0].target,
     $tgt = $(tgt);

 if (tgt.nodeName !== 'A' && !$tgt.closest('div.cluetip').length ) {
   $(document).trigger('hideCluetip');
 }
});

$('some-already-initialized-link').trigger('showCluetip')
{% endhighlight %}

工作中的使用样例：
  	$(".float_user_card").card_float({
		card_floatClass: "user_card_float",
		width:340,
		leftOffset: 4,
		arrows: true,
		sticky: true,
		mouseOutClose: "both",
		closeText:'',
		waitImage:false,
		arrows:false
	});
  具有一定的借鉴意义。

Triggers the cluetip to be shown for a particular element on which .cluetip() has already been called.

    height: Setting a specific height also sets <div id="cluetip-outer"> to "overflow:auto"
    positionBy: Available options are 'auto', 'mouse', 'bottomTop', 'topBottom', fixed'. Change to 'mouse' if you want to override positioning by element and position the clueTip based on where the mouse is instead. Change to 'bottomTop' if you want positioning to begin below the mouse when there is room or above if not (and 'topBottom' for vice versa) — rather than right or left of the elemnent and flush with element's top. Change to 'fixed' if you want the clueTip to appear in exactly the same location relative to the linked element no matter where it appears on the page. Use 'fixed' at your own risk.
    topOffset:For all but positionBy: 'fixed', the number will be added to the clueTip's "top" value if the clueTip appears below the invoking element and subtracted from it if the clueTip appears above. For positionBy "fixed", the number will always be added to the "top" value, offsetting the clueTip from the top of the invoking element.
    leftOffset: For all but positionBy: 'fixed', the number will be added to clueTip's "left" value if the clueTip appears to the right of the invoking element and subtracted if the clueTip appears to the left. For positionBy "fixed", the number will always be added to the "left" value of the clueTip, offsetting it from the right side of the invoking element.
    local: for example, using the default tip attribute, "rel", you could have a link — <a href="somewhere.htm" rel="#someID"> — that would show the contents of the element in the DOM that has an ID of "someID."
    Important: If you use any selector other than a simple ID, the plugin will match the index of the element with the index of the invoking element among all selected elements. For example, if you call $('a').cluetip({local: true}) and you have two links with rel="div.foo", the first link will display the contents of the first div class="foo" and the second link will display the contents of the second div class="foo".
    splitTitle: if used, the clueTip will be populated only by the title attribute
    cluetipClass: this is also used for a "directional" class on the same div, depending on where the clueTip is in relation to the invoking element. The class appears in the form of 'cluetip-' + direction + cluetipClass. this allows you to create your own clueTip theme in a separate CSS file or use one of the three pre-packaged themes: default, jtip, or rounded.
    arrows: UPDATE: this option displays a div containing an arrow background image. Arrow images are set using the background-image property in the CSS. The direction of the arrow changes depending on which side of the invoking element the clueTip appears. The arrows option sets the background-position of the cluetip div so that the arrow will accurately point to the invoking element, regardless of where it appears in relation to it.

Frequently Asked Questions

How is clueTip licensed?

    The clueTip plugin is licensed the same way as the jQuery core file: under the MIT license. The top of the jquery.cluetip.js file has this notice:

    Licensed under the MIT license:
    * http://www.opensource.org/licenses/mit-license.php
What versions of jQuery is the clueTip Plugin compatible with?
    As of clueTip version 1.06, the plugin is compatible with version 1.3.2 or later. Previous clueTip versions are compatible with jQuery 1.2.6, though 1.3.2 or later is recommended.
Does the clueTip Plugin have any dependencies on other plugins?
    No. However, optional plugins that can be used in conjunction with the clueTip plugin include hoverIntent and bgIframe.
How do I get clueTip to work on elements that have been inserted via ajax after the page loads?
    You can call the .cluetip() method on those elements from within the ajax method's callback function. For example:
{% highlight javascript %}
$.get('/path/to/file', function(html) {
  var newHtml = $(html);
  newHtml.appendTo('#some-elememnt');
  newHtml.find('a').cluetip();
});
{% endhighlight %}
How do I get clueTip to show ajaxed content that has changed on the server?
    There are a number of options available for working with dynamic content. By default, the ajaxCache function is set to true. This reduces the number of http requests made to the server. However, it doesn't account for possible changes to the ajaxed data. If the contents of a particular clueTip will be updated on the server between invocations, you may want to set ajaxCache: false. 
How do I programmatically close (hide) a clueTip?
    If you want to trigger a clueTip to close, based on some other interaction, you can use the following code: $(document).trigger('hideCluetip'); 
Why don't the styles that I've applied to my local content carry over once they're inside a clueTip?
    When using an element on the same page to populate the clueTip's content, the plugin clones that element. Because of potential problems caused by duplicate IDs within a page, the plugin also, by default, adds a suffix to the ID of the cloned element. If you have tied styles to the original ID, they won't be carried over. You can either give the localIdSuffix an empty string ( '' ) for its value or add the ID to your stylesheet rule.
Why don't form elements within a clueTip update when I tell them to?
    If you attempt to update an element based on its ID,
How do I add a delay before showing or closing the clueTip?
    While the clueTip plugin itself doesn't have a mechanism for delaying responses, it can take advantage of the optional hoverIntent plugin. To delay the showing of a clueTip, use the interval property of the hoverIntent option; to delay its hiding, use the timeout property. Both properties are measured in milliseconds. For example, the following sets both the show and the hide delays to 750 milliseconds (3/4 second):

    $('a').cluetip({
      hoverIntent: {
        sensitivity:  1,
        interval:     750,
        timeout:      750
      }
    });

    See hoverIntent plugin's documentation for details.

Why are the clueTips hidden behind my Flash elements?

    This is a common problem when trying to layer a DOM element over a Flash object. To avoid it, you need to set <param name="wmode" value="transparent" /> inside the <object></object> tags and/or wmode="transparent" as an attribute of the <embed /> tag. For example, your HTML might look like this:

    <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
      codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab"
      width="500" height="300">
      <param name="movie" value="test.swf" />
      <param name="quality" value="high" />
      <param name="wmode" value="transparent" />

      <embed src="test.swf" quality="high" wmode="transparent"
        pluginspage="http://www.macromedia.com/go/getflashplayer"
        type="application/x-shockwave-flash" width="500" height="300" />
    </object>

## 后记
----

工作是需求的来源，能力的成长来自压力。原本我的定位是Rails程序员，结果，JQuery要懂点，JS也要写点。看来以后要这么介绍自己，哥就是编程的。

