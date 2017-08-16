# KTJPushQueueForNavigation
当使用某个页面还没有进行viewDidAppear:的时候再进行一次推页面是不安全的。

苹果在iPhone5C iOS7.1.2中Push时给出的警告：
> “nested push animation can result in corrupted navigation bar. Finishing up a navigation transition in an unexpected state. Navigation Bar subview tree might get corrupted.”

这说明这个不安全的操作可能会导致应用Crash，Crash统计系统统计的原因为：“Can't add self as subview”。

本文解决该Crash，实现嵌套安全的去推页面。

分析及其他方案见 [blog](https://madordie.github.io/push-queue-for-navigation/)
