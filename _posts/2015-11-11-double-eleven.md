---
layout: post
title:  "双十一的纪念"
description: "jquery validation, 双十一的纪念"
category: note
---
 
## 前言
 
看到自己以前写的 jquery 验证的代码被注释掉了, 心想, 留恋一下, 拷贝如下:
 
```
/*
$(".get_verification_code").click(function () {
  send_code("#user_name", this, "sign_up", false);
});
$(".form_horizontal_sign_up").validate({
  messages: {
    user_name: {
      required: '必填，且为4-20个汉字、字母、数字的组合'
    },
    verify_code: {
      required: '必填'
    },
    password: {
      required: "必填，且长度为6",
      minlength: jQuery.validator.format("至少输入 {0} 个字符")
    },
    password_confirm: {
      required: "必填，且长度为6",
      minlength: jQuery.validator.format("至少输入 {0} 个字符"),
      equalTo: "请输入与上面相同的密码"
    }
  },
  submitHandler: function (form) {
    validate_code("#user_name",
            "#verify_code",
            "sign_up",
            function(status){
              if(checkService() && status) {
                form.submit();
              }
            });
  }
});
*/
```