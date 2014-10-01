---
layout: post
title: JQuery插件-validation
---

某个部分需要用到该插件来验证表单，所以需要了解一下，下面是其文档的部分翻译:

- 文档的地址: http://jqueryvalidation.org/documentation/
- 指导原则地址: http://jqueryvalidation.org/reference
- validate选项: http://jqueryvalidation.org/validate

## 以从未有过的方式验证表单(Validate forms like you've never validated before!)

**"jQuery不是已经使插件的编写更加容易(But doesn't jQuery make it easy to write your own validation plugin)？"**

Sure, but there are still a lot of subtleties to take care of: You need a standard library of validation methods (such as emails, URLs, credit card numbers). You need to place error messages in the DOM and show and hide them when appropriate. You want to react to more than just a submit event, like keyup and blur.

当然，但是依然存在很多的细节需要了解，比如： 需要验证方法的标准库(email,URL,信用卡数)，合适恰当的需要处理错误消息的显示，需要不仅仅是一个表单提交事件(keyup和blur)

You may need different ways to specify validation rules according to the server-side enviroment you are using on different projects. And after all, you don't want to reinvent the wheel, do you?

根据服务器端环境，需要不同的方式指定验证规则，并且不想重造轮子。

**"不是已经存在一打的验证插件(But aren't there already a ton of validation plugins out there)?"**

Right, there are a lot of non-jQuery-based solutions (which you'd avoid since you found jQuery) and some jQuery-based solutions. This particular one is one of the oldest jQuery plugins (started in July 2006) and has proved itself in projects all around the world. There is also an article discussing how this plugin fits the bill of the should-be validation solution.

确实存在很多jQuery的以及非jQuery的解决方案。特别是其中最老的一个jQuery插件。


Not convinced? Have a look at this example:

    <form class="cmxform" id="commentForm" method="get" action="">
      <fieldset>
        <legend>Please provide your name, email address (won't be published) and a comment</legend>
        <p>
          <label for="cname">Name (required, at least 2 characters)</label>
          <input id="cname" name="name" minlength="2" type="text" required/>
        </p>
        <p>
          <label for="cemail">E-Mail (required)</label>
          <input id="cemail" type="email" name="email" required/>
        </p>
        <p>
          <label for="curl">URL (optional)</label>
          <input id="curl" type="url" name="url"/>
        </p>
        <p>
          <label for="ccomment">Your comment (required)</label>
          <textarea id="ccomment" name="comment" required></textarea>
        </p>
        <p>
          <input class="submit" type="submit" value="Submit"/>
        </p>
      </fieldset>
    </form>
    <script>
    $("#commentForm").validate();
    </script>

Isn't that nice and easy?

A single line of jQuery to select the form and apply the validation plugin, plus a few annotations on each element to specify the validation rules.

Of course that isn't the only way to specify rules. You also don't have to rely on those default messages, but they come in handy when starting to setup validation for a form.
A few things to look out for when playing around with the demo

    After trying to submit an invalid form, the first invalid element is focused, allowing the user to correct the field. If another invalid field – that wasn't the first one – was focused before submit, that field is focused instead, allowing the user to start at the bottom if he or she prefers.
    Before a field is marked as invalid, the validation is lazy: Before submitting the form for the first time, the user can tab through fields without getting annoying messages – they won't get bugged before having the chance to actually enter a correct value
    Once a field is marked invalid, it is eagerly validated: As soon as the user has entered the necessary value, the error message is removed
    If the user enters something in a non-marked field, and tabs/clicks away from it (blur the field), it is validated – obviously the user had the intention to enter something, but failed to enter the correct value

That behaviour can be irritating when clicking through demos of the validation plugin – it is designed for an unobtrusive user experience, annoying the user as little as possible with unnecessary error messages. So when you try out other demos, try to react like one of your users would, and see if the behaviour is better then. If not, please let me know about any ideas you may have for improvements!

API Documentation

You're probably looking for [Options for the validate() method](http://jqueryvalidation.org/validate)

If not, read on.

Throughout the documentation, two terms are used very often, so it's important that you know their meaning in the context of the validation plugin:

Throughout the documentation, two terms are used very often, so it's important that you know their meaning in the context of the validation plugin:

-  method: A validation method implements the logic to validate an element, like an email method that checks for the right format of a text input's value. A set of standard methods is available, and it is easy to write your own.
-  rule: A validation rule associates an element with a validation method, like "validate input with name "primary-mail" with methods "required" and "email".

Plugin methods

This library adds three jQuery plugin methods, the main entry point being the validate method:

- validate() – Validates the selected form.
- valid() – Checks whether the selected form or selected elements are valid.
- rules() – Read, add and remove rules for an element.

Custom selectors

This library also extends jQuery with three custom selectors:

    :blank – Selects all elements with a blank value.
    :filled – Selects all elements with a filled value.
    :unchecked – Selects all elements that are unchecked.
Validator

The validate method returns a Validator object that has a few public methods that you can use to trigger validation programmatically or change the contents of the form. The validator object has more methods, but only those documented here are intended for usage.

    Validator.form() – Validates the form.
    Validator.element() – Validates a single element.
    Validator.resetForm() – Resets the controlled form.
    Validator.showErrors() – Show the specified messages.
    Validator.numberOfInvalids() – Returns the number of invalid fields.

There are a few static methods on the validator object:

    jQuery.validator.addMethod() – Add a custom validation method.
    jQuery.validator.format() – Replaces {n} placeholders with arguments.
    jQuery.validator.setDefaults() – Modify default settings for validation.
    jQuery.validator.addClassRules() – Add a compound class method.

List of built-in Validation methods

A set of standard validation methods is provided:

    required – Makes the element required.
    remote – Requests a resource to check the element for validity.
    minlength – Makes the element require a given minimum length.
    maxlength – Makes the element require a given maxmimum length.
    rangelength – Makes the element require a given value range.
    min – Makes the element require a given minimum.
    max – Makes the element require a given maximum.
    range – Makes the element require a given value range.
    email – Makes the element require a valid email
    url – Makes the element require a valid url
    date – Makes the element require a date.
    dateISO – Makes the element require an ISO date.
    number – Makes the element require a decimal number.
    digits – Makes the element require digits only.
    creditcard – Makes the element require a credit card number.
    equalTo – Requires the element to be the same as another one

Some more methods are provided as add-ons, and are currently included in additional-methods.js in the download package. Not all of them are documented here:

    accept – Makes a file upload accept only specified mime-types.
    extension – Makes the element require a certain file extension.
    phoneUS – Validate for valid US phone number.
    require_from_group – Ensures a given number of fields in a group are complete.


General Guidelines

The General Guidelines section provides detailed discussion of the design and ideas behind the plugin, explaining why certain things are as they are. It covers the features in more detail than the API documentation, which just briefly explains the various methods and options available.

If you've decided to use the validation plugin in your application and want to get to know it better, it is recommended that you read the guidelines.

Fields with complex names (brackets, dots)

When you have a name attribute like `user[name]`, make sure to put the name in quotes. More details in the [General Guidelines](http://jqueryvalidation.org/reference).

Too much recursion

Another common problem occurs with this code:

$("#myform").validate({
  gv"_csubmitHandler: function(form) {
    // some other code
    // maybe disabling submit button
    // then:
    $(form).submit();
  }
});

his results in a too-much-recursion error: $(form).submit() triggers another round of validation, resulting in another call to submitHandler, and voila, recursion. Replace that with form.submit(), which triggers the native submit event instead and not the validation.

So the correct code looks slightly different:

$("#myform").validate({
  submitHandler: function(form) {
    form.submit();
  }
});

## Demos


